#pragma once

#include "SparseCoder.h"
#include "Predictor.h"

namespace neo {
	class PredictiveHierarchy {
	public:
		struct LayerDesc {
			cl_int2 _size;

			cl_int _feedForwardRadius, _recurrentRadius, _feedBackRadius, _predictiveRadius;

			cl_int _scIterations;
			cl_float _scStepSize;
			cl_float _scLeak;
			cl_float _scWeightAlpha;
			cl_float _scThresholdAlpha;
			cl_float _scWeightTraceLambda;
			cl_float _scActiveRatio;

			cl_float _baseLineDecay;
			cl_float _baseLineSensitivity;
			
			cl_float _predWeightAlpha;

			LayerDesc()
				: _size({ 8, 8 }),
				_feedForwardRadius(5), _recurrentRadius(5), _feedBackRadius(5), _predictiveRadius(5),
				_scIterations(17), _scStepSize(1.1f), _scLeak(0.01f),
				_scWeightAlpha(0.001f), _scThresholdAlpha(0.02f),
				_scWeightTraceLambda(0.95f), _scActiveRatio(0.2f),
				_baseLineDecay(0.01f), _baseLineSensitivity(4.0f),
				_predWeightAlpha(0.01f)
			{}
		};

		struct Layer {
			SparseCoder _sc;
			Predictor _pred;

			DoubleBuffer2D _baseLines;

			cl::Image2D _reward;
		};

	private:
		std::vector<Layer> _layers;
		std::vector<LayerDesc> _layerDescs;

		Predictor _firstLayerPred;

		cl::Kernel _baseLineUpdateKernel;

	public:
		cl_float _predWeightAlpha;

		PredictiveHierarchy()
			: _predWeightAlpha(0.005f)
		{}

		void createRandom(sys::ComputeSystem &cs, sys::ComputeProgram &program,
			cl_int2 inputSize, cl_int firstLayerPredictorRadius, const std::vector<LayerDesc> &layerDescs,
			cl_float2 initWeightRange, cl_float initThreshold,
			cl_float2 initCodeRange, cl_float2 initReconstructionErrorRange, std::mt19937 &rng);

		void simStep(sys::ComputeSystem &cs, const cl::Image2D &input, bool learn = true);

		size_t getNumLayers() const {
			return _layers.size();
		}

		const Layer &getLayer(int index) const {
			return _layers[index];
		}

		const LayerDesc &getLayerDescs(int index) const {
			return _layerDescs[index];
		}

		const Predictor &getFirstLayerPred() const {
			return _firstLayerPred;
		}
	};
}