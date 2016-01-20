#include "AgentPredQ.h"

using namespace neo;

void AgentPredQ::createRandom(sys::ComputeSystem &cs, sys::ComputeProgram &program,
	cl_int2 inputSize, cl_int2 actionSize, cl_int2 qSize, const std::vector<LayerDesc> &layerDescs,
	cl_float2 initWeightRange,
	std::mt19937 &rng)
{
	_inputSize = inputSize;
	_actionSize = actionSize;
	_qSize = qSize;

	_layerDescs = layerDescs;
	_layers.resize(_layerDescs.size());

	cl_int2 prevLayerSize = inputSize;

	for (int l = 0; l < _layers.size(); l++) {
		std::vector<SparsePredictor::VisibleLayerDesc> spDescs;

		if (l == 0) {
			spDescs.resize(4);

			spDescs[0]._size = prevLayerSize;
			spDescs[0]._encodeRadius = _layerDescs[l]._feedForwardRadius;
			spDescs[0]._predDecodeRadius = _layerDescs[l]._predictiveRadius;
			spDescs[0]._feedBackDecodeRadius = _layerDescs[l]._feedBackRadius;
			spDescs[0]._predictThresholded = false;
			spDescs[0]._predict = true;
			spDescs[0]._useForInput = true;

			spDescs[1]._size = _layerDescs[l]._size;
			spDescs[1]._encodeRadius = _layerDescs[l]._recurrentRadius;
			spDescs[1]._predDecodeRadius = _layerDescs[l]._predictiveRadius;
			spDescs[1]._feedBackDecodeRadius = _layerDescs[l]._feedBackRadius;
			spDescs[1]._predictThresholded = true;
			spDescs[1]._predict = false;
			spDescs[1]._useForInput = true;

			spDescs[2]._size = _actionSize;
			spDescs[2]._encodeRadius = _layerDescs[l]._feedForwardRadius;
			spDescs[2]._predDecodeRadius = _layerDescs[l]._predictiveRadius;
			spDescs[2]._feedBackDecodeRadius = _layerDescs[l]._feedBackRadius;
			spDescs[2]._predictThresholded = false;
			spDescs[2]._predict = true;
			spDescs[2]._useForInput = true;

			spDescs[3]._size = _qSize;
			spDescs[3]._encodeRadius = _layerDescs[l]._feedForwardRadius;
			spDescs[3]._predDecodeRadius = _layerDescs[l]._predictiveRadius;
			spDescs[3]._feedBackDecodeRadius = _layerDescs[l]._feedBackRadius;
			spDescs[3]._predictThresholded = false;
			spDescs[3]._predict = true;
			spDescs[3]._useForInput = false;
		}
		else {
			spDescs.resize(2);

			spDescs[0]._size = prevLayerSize;
			spDescs[0]._encodeRadius = _layerDescs[l]._feedForwardRadius;
			spDescs[0]._predDecodeRadius = _layerDescs[l]._predictiveRadius;
			spDescs[0]._feedBackDecodeRadius = _layerDescs[l]._feedBackRadius;
			spDescs[0]._predictThresholded = true;
			spDescs[0]._predict = true;
			spDescs[0]._useForInput = true;

			spDescs[1]._size = _layerDescs[l]._size;
			spDescs[1]._encodeRadius = _layerDescs[l]._recurrentRadius;
			spDescs[1]._predDecodeRadius = _layerDescs[l]._predictiveRadius;
			spDescs[1]._feedBackDecodeRadius = _layerDescs[l]._feedBackRadius;
			spDescs[1]._predictThresholded = true;
			spDescs[1]._predict = false;
			spDescs[1]._useForInput = true;
		}

		std::vector<cl_int2> feedBackSizes;

		if (l < _layers.size() - 1) {
			feedBackSizes.resize(4);

			feedBackSizes[0] = feedBackSizes[1] = feedBackSizes[2] = feedBackSizes[3] = _layerDescs[l + 1]._size;
		}
		else {
			feedBackSizes.resize(2);

			feedBackSizes[0] = feedBackSizes[1] = { 1, 1 };
		}

		_layers[l]._sp.createRandom(cs, program, spDescs, _layerDescs[l]._size, feedBackSizes, _layerDescs[l]._lateralRadius, initWeightRange, rng);

		_layers[l]._additionalErrors = cl::Image2D(cs.getContext(), CL_MEM_READ_WRITE, cl::ImageFormat(CL_R, CL_FLOAT), prevLayerSize.x, prevLayerSize.y);

		cs.getQueue().enqueueFillImage(_layers[l]._additionalErrors, cl_float4{ 0.0f, 0.0f, 0.0f, 0.0f }, { 0, 0, 0 }, { static_cast<cl::size_type>(prevLayerSize.x), static_cast<cl::size_type>(prevLayerSize.y), 1 });

		prevLayerSize = _layerDescs[l]._size;
	}

	_qInputLayer = cl::Image2D(cs.getContext(), CL_MEM_READ_WRITE, cl::ImageFormat(CL_R, CL_FLOAT), _qSize.x, _qSize.y);
	_qRetrievalLayer = cl::Image2D(cs.getContext(), CL_MEM_READ_WRITE, cl::ImageFormat(CL_R, CL_FLOAT), _qSize.x, _qSize.y);

	// Create a random Q transform
	_qTransforms = cl::Image2D(cs.getContext(), CL_MEM_READ_WRITE, cl::ImageFormat(CL_R, CL_FLOAT), _qSize.x, _qSize.y);

	cl::Kernel randomUniformXYKernel = cl::Kernel(program.getProgram(), "randomUniformXY");

	randomUniformXY(_qTransforms, cs, randomUniformXYKernel, _qSize, { -1.0f, 1.0f }, rng);

	_inputWhitener.create(cs, program, _inputSize, CL_R, CL_FLOAT);

	_zeroLayer = cl::Image2D(cs.getContext(), CL_MEM_READ_WRITE, cl::ImageFormat(CL_R, CL_FLOAT), 1, 1);

	cs.getQueue().enqueueFillImage(_zeroLayer, cl_float4{ 0.0f, 0.0f, 0.0f, 0.0f }, { 0, 0, 0 }, { 1, 1, 1 });

	_setQKernel = cl::Kernel(program.getProgram(), "pqSetQ");
	_getQKernel = cl::Kernel(program.getProgram(), "pqGetQ");
}

void AgentPredQ::simStep(sys::ComputeSystem &cs, float reward, const cl::Image2D &input, const cl::Image2D &actionTaken, bool learn, bool whiten) {
	// Whiten input
	if (whiten)
		_inputWhitener.filter(cs, input, _whiteningKernelRadius, _whiteningIntensity);

	// Feed forward
	cl::Image2D prevLayerState = whiten ? _inputWhitener.getResult() : input;

	for (int l = 0; l < _layers.size(); l++) {
		std::vector<cl::Image2D> visibleStates;

		if (l == 0) {
			visibleStates.resize(4);

			visibleStates[0] = prevLayerState;
			visibleStates[1] = _layers[l]._sp.getHiddenStates()[_back];
			visibleStates[2] = actionTaken;
			visibleStates[3] = _zeroLayer; // Unused as input
		}
		else {
			visibleStates.resize(2);

			visibleStates[0] = prevLayerState;
			visibleStates[1] = _layers[l]._sp.getHiddenStates()[_back];
		}

		_layers[l]._sp.activateEncoder(cs, visibleStates, _layerDescs[l]._spActiveRatio);

		prevLayerState = _layers[l]._sp.getHiddenStates()[_front];
	}

	// Feed back
	for (int l = _layers.size() - 1; l >= 0; l--) {
		std::vector<cl::Image2D> feedBackStates;

		if (l < _layers.size() - 1) {
			if (l == 0) {
				feedBackStates.resize(4);

				feedBackStates[0] = feedBackStates[1] = feedBackStates[2] = feedBackStates[3] = _layers[l + 1]._sp.getVisibleLayer(0)._predictions[_back];
			}
			else {
				feedBackStates.resize(2);

				feedBackStates[0] = feedBackStates[1] = _layers[l + 1]._sp.getVisibleLayer(0)._predictions[_back];
			}
		}
		else {
			if (l == 0) {
				feedBackStates.resize(4);

				feedBackStates[0] = feedBackStates[1] = feedBackStates[2] = feedBackStates[3] = _zeroLayer;
			}
			else {
				feedBackStates.resize(2);

				feedBackStates[0] = feedBackStates[1] = _zeroLayer;
			}
		}

		_layers[l]._sp.activateDecoder(cs, feedBackStates);
	}

	// Un-transform Q
	{
		int argIndex = 0;

		_getQKernel.setArg(argIndex++, _layers.front()._sp.getVisibleLayer(3)._predictions[_back]);
		_getQKernel.setArg(argIndex++, _qTransforms);
		_getQKernel.setArg(argIndex++, _qRetrievalLayer);

		cs.getQueue().enqueueNDRangeKernel(_getQKernel, cl::NullRange, cl::NDRange(_qSize.x, _qSize.y));
	}

	// Retrieve Q
	std::vector<float> qRetrieve(_qSize.x * _qSize.y);

	cs.getQueue().enqueueReadImage(_qRetrievalLayer, CL_TRUE, { 0, 0, 0 }, { static_cast<cl::size_type>(_qSize.x), static_cast<cl::size_type>(_qSize.y), 1 }, 0, 0, qRetrieve.data());

	float q = 0.0f;

	for (int i = 0; i < qRetrieve.size(); i++)
		q += qRetrieve[i];

	q /= qRetrieve.size();

	float tdError = reward + _qGamma * q - _prevValue;

	float newQ = _prevValue + _qAlpha * tdError;

	_prevValue = q;

	// Encode target Q
	{
		int argIndex = 0;

		_setQKernel.setArg(argIndex++, _qTransforms);
		_setQKernel.setArg(argIndex++, _qInputLayer);
		_setQKernel.setArg(argIndex++, newQ);

		cs.getQueue().enqueueNDRangeKernel(_setQKernel, cl::NullRange, cl::NDRange(_qSize.x, _qSize.y));
	}

	if (learn) {
		// Feed forward
		prevLayerState = input;

		for (int l = 0; l < _layers.size(); l++) {
			// Encoder
			std::vector<cl::Image2D> visibleStates;

			if (l == 0) {
				visibleStates.resize(4);

				visibleStates[0] = prevLayerState;
				visibleStates[1] = _layers[l]._sp.getHiddenStates()[_front];
				visibleStates[2] = actionTaken;
				visibleStates[3] = _qInputLayer;
			}
			else {
				visibleStates.resize(2);

				visibleStates[0] = prevLayerState;
				visibleStates[1] = _layers[l]._sp.getHiddenStates()[_front];
			}

			std::vector<cl::Image2D> feedBackStates;

			if (l < _layers.size() - 1) {
				if (l == 0) {
					feedBackStates.resize(4);

					feedBackStates[0] = feedBackStates[1] = feedBackStates[2] = feedBackStates[3] = _layers[l + 1]._sp.getVisibleLayer(0)._predictions[_back];
				}
				else {
					feedBackStates.resize(2);

					feedBackStates[0] = feedBackStates[1] = _layers[l + 1]._sp.getVisibleLayer(0)._predictions[_back];
				}
			}
			else {
				if (l == 0) {
					feedBackStates.resize(4);

					feedBackStates[0] = feedBackStates[1] = feedBackStates[2] = feedBackStates[3] = _zeroLayer;
				}
				else {
					feedBackStates.resize(2);

					feedBackStates[0] = feedBackStates[1] = _zeroLayer;
				}
			}

			_layers[l]._sp.learn(cs, visibleStates, feedBackStates,
				l == 0 ? std::vector<cl::Image2D>{ _layers[l]._additionalErrors, _layers[l]._additionalErrors, _layers[l]._additionalErrors, _layers[l]._additionalErrors } : std::vector<cl::Image2D>{ _layers[l]._additionalErrors, _layers[l]._additionalErrors },
				_layerDescs[l]._spWeightAlpha, _layerDescs[l]._spWeightLambda, _layerDescs[l]._spBiasAlpha, _layerDescs[l]._spActiveRatio, _layerDescs[l]._spRMSDecay, _layerDescs[l]._spRMSEpsilon);

			prevLayerState = _layers[l]._sp.getHiddenStates()[_back];
		}
	}
}