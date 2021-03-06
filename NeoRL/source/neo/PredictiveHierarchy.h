#pragma once

#include "SparsePredictor.h"
#include "ImageWhitener.h"

namespace neo {
	/*!
	\brief Predictive hierarchy (no RL)
	*/
	class PredictiveHierarchy {
	public:
		/*!
		\brief Layer desc
		*/
		struct LayerDesc {
			/*!
			\brief Size of layer
			*/
			cl_int2 _size;

			/*!
			\brief Radii
			*/
			cl_int _feedForwardRadius, _recurrentRadius, _lateralRadius, _feedBackRadius, _predictiveRadius;

			//!@{
			/*!
			\brief Sparse predictor parameters
			*/
			cl_float _spWeightEncodeAlpha;
			cl_float _spWeightDecodeAlpha;
			cl_float _spWeightLambda;
			cl_float _spActiveRatio;
			cl_float _spBiasAlpha;
			//!@}

			/*!
			\brief Initialize defaults
			*/
			LayerDesc()
				: _size({ 8, 8 }),
				_feedForwardRadius(5), _recurrentRadius(5), _lateralRadius(5), _feedBackRadius(6), _predictiveRadius(6),
				_spWeightEncodeAlpha(0.001f), _spWeightDecodeAlpha(0.02f), _spWeightLambda(0.9f),
				_spActiveRatio(0.08f), _spBiasAlpha(0.1f)
			{}
		};

		/*!
		\brief Layer
		*/
		struct Layer {
			/*!
			\brief Sparse predictor
			*/
			SparsePredictor _sp;

			/*!
			\brief Layer for additional error signals
			*/
			cl::Image2D _additionalErrors;
		};

	private:
		/*!
		\brief Store input size
		*/
		cl_int2 _inputSize;

		//!@{
		/*!
		\brief Layers and descs
		*/
		std::vector<Layer> _layers;
		std::vector<LayerDesc> _layerDescs;
		//!@}

		/*!
		\brief Input whitener
		*/
		ImageWhitener _inputWhitener;

		/*!
		\brief Zero layer for capping of the network
		*/
		cl::Image2D _zeroLayer;

	public:
		//!@{
		/*!
		\brief Whitening parameters
		*/
		cl_int _whiteningKernelRadius;
		cl_float _whiteningIntensity;
		//!@}

		/*!
		\brief Initialize defaults
		*/
		PredictiveHierarchy()
			: _whiteningKernelRadius(1),
			_whiteningIntensity(1024.0f)
		{}

		/*!
		\brief Create a predictive hierarchy with random initialization
		Requires the compute system, program with the NeoRL kernels, and initialization information
		*/
		void createRandom(sys::ComputeSystem &cs, sys::ComputeProgram &program,
			cl_int2 inputSize, const std::vector<LayerDesc> &layerDescs,
			cl_float2 initWeightRange,
			std::mt19937 &rng);

		/*!
		\brief Simulation step of hierarchy
		*/
		void simStep(sys::ComputeSystem &cs, const cl::Image2D &input, bool learn = true, bool whiten = false);

		/*!
		\brief Get number of layers
		*/
		size_t getNumLayers() const {
			return _layers.size();
		}

		/*!
		\brief Get access to a layer
		*/
		const Layer &getLayer(int index) const {
			return _layers[index];
		}

		/*!
		\brief Get access to a layer desc
		*/
		const LayerDesc &getLayerDescs(int index) const {
			return _layerDescs[index];
		}

		/*!
		\brief Get the prediction
		*/
		const cl::Image2D &getPrediction() const {
			return _layers.front()._sp.getVisibleLayer(0)._predictions[_back];
		}

		/*!
		\brief Get input whitener
		*/
		const ImageWhitener &getInputWhitener() const {
			return _inputWhitener;
		}
	};
}