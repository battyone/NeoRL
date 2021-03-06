// ----------------------------------------- Samplers -----------------------------------------

constant sampler_t normalizedClampedNearestSampler = CLK_NORMALIZED_COORDS_TRUE |
	CLK_ADDRESS_CLAMP |
	CLK_FILTER_NEAREST;

constant sampler_t normalizedClampedToEdgeNearestSampler = CLK_NORMALIZED_COORDS_TRUE |
	CLK_ADDRESS_CLAMP_TO_EDGE |
	CLK_FILTER_NEAREST;

constant sampler_t unnormalizedClampedNearestSampler = CLK_NORMALIZED_COORDS_FALSE |
	CLK_ADDRESS_CLAMP |
	CLK_FILTER_NEAREST;

constant sampler_t defaultNormalizedSampler = CLK_NORMALIZED_COORDS_TRUE |
	CLK_ADDRESS_CLAMP_TO_EDGE |
	CLK_FILTER_NEAREST;

constant sampler_t defaultUnnormalizedSampler = CLK_NORMALIZED_COORDS_FALSE |
	CLK_ADDRESS_CLAMP_TO_EDGE |
	CLK_FILTER_NEAREST;

// ----------------------------------------- Common -----------------------------------------

constant float minFloatEpsilon = 0.0001f;

float randFloat(uint2* state) {
	const float invMaxInt = 1.0f / 4294967296.0f;
	uint x = (*state).x * 17 + (*state).y * 13123;
	(*state).x = (x << 13) ^ x;
	(*state).y ^= (x << 7);

	uint tmp = x * (x * x * 15731 + 74323) + 871483;

	return convert_float(tmp) * invMaxInt;
}

float randNormal(uint2* state) {
	float u1 = randFloat(state);
	float u2 = randFloat(state);

	return sqrt(-2.0f * log(u1)) * cos(6.28318f * u2);
}

float sigmoid(float x) {
	return 1.0f / (1.0f + exp(-x));
}

float relu(float x, float leak) {
	if (x > 1.0f)
		return 1.0f + (x - 1.0f) * leak;

	return x > 0.0f ? x : x * leak;
}

float relud(float x, float leak) {
	return x > 0.0f && x < 1.0f ? 1.0f : leak;
}

float elu(float x, float alpha) {
	return x >= 0.0f ? x : alpha * (exp(x) - 1.0f);
}

float elud(float x, float alpha) {
	return x >= 0.0f ? 1.0f : x + alpha;
}

bool inBounds0(int2 position, int2 upperBound) {
	return position.x >= 0 && position.x < upperBound.x && position.y >= 0 && position.y < upperBound.y;
}

bool inBounds(int2 position, int2 lowerBound, int2 upperBound) {
	return position.x >= lowerBound.x && position.x < upperBound.x && position.y >= lowerBound.y && position.y < upperBound.y;
}

// Initialize a random uniform 2D image (X field)
void kernel randomUniform2D(write_only image2d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 29 + 12, get_global_id(1) * 16 + 23) * 36;

	int2 position = (int2)(get_global_id(0), get_global_id(1));

	float value = randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x;

	write_imagef(values, position, (float4)(value, 0.0f, 0.0f, 0.0f));
}

// Initialize a random uniform 3D image (X field)
void kernel randomUniform3D(write_only image3d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 12 + 76 + get_global_id(2) * 3, get_global_id(1) * 21 + 42 + get_global_id(2) * 7) * 12;

	int3 position = (int3)(get_global_id(0), get_global_id(1), get_global_id(2));

	float value = randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x;

	write_imagef(values, (int4)(position, 0), (float4)(value, 0.0f, 0.0f, 0.0f));
}

// Initialize a random uniform 2D image (XY fields)
void kernel randomUniform2DXY(write_only image2d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 15 + 66, get_global_id(1) * 61 + 2) * 56;

	int2 position = (int2)(get_global_id(0), get_global_id(1));

	float2 v = (float2)(randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x);

	write_imagef(values, position, (float4)(v.x, v.y, 0.0f, 0.0f));
}

// Initialize a random uniform 2D image (XYZ fields)
void kernel randomUniform2DXYZ(write_only image2d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 15 + 66, get_global_id(1) * 61 + 2) * 56;

	int2 position = (int2)(get_global_id(0), get_global_id(1));

	float3 v = (float3)(randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x);

	write_imagef(values, position, (float4)(v.x, v.y, v.z, 0.0f));
}

// Initialize a random uniform 2D image (XZ fields)
void kernel randomUniform2DXZ(write_only image2d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 29 + 12, get_global_id(1) * 16 + 23) * 36;

	int2 position = (int2)(get_global_id(0), get_global_id(1));

	float2 v = (float2)(randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x);

	write_imagef(values, position, (float4)(v.x, 0.0f, v.y, 0.0f));
}

// Initialize a random uniform 3D image (XY fields)
void kernel randomUniform3DXY(write_only image3d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 12 + 76 + get_global_id(2) * 3, get_global_id(1) * 21 + 42 + get_global_id(2) * 7) * 12;

	int3 position = (int3)(get_global_id(0), get_global_id(1), get_global_id(2));

	float2 v = (float2)(randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x);

	write_imagef(values, (int4)(position, 0), (float4)(v.x, v.y, 0.0f, 0.0f));
}

// Initialize a random uniform 3D image (XZ fields)
void kernel randomUniform3DXZ(write_only image3d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 12 + 76 + get_global_id(2) * 3, get_global_id(1) * 21 + 42 + get_global_id(2) * 7) * 12;

	int3 position = (int3)(get_global_id(0), get_global_id(1), get_global_id(2));

	float2 v = (float2)(randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x);

	write_imagef(values, (int4)(position, 0), (float4)(v.x, 0.0f, v.y, 0.0f));
}

// ----------------------------------------- Comparison Sparse Coder -----------------------------------------

void kernel cscActivate(read_only image2d_t visibleStates,
	read_only image2d_t hiddenSummationTempBack, write_only image2d_t hiddenSummationTempFront, read_only image3d_t weights,
	int2 visibleSize, float2 hiddenToVisible, int radius)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float sum = read_imagef(hiddenSummationTempBack, hiddenPosition).x;

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float subSum = 0.0f;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float state = read_imagef(visibleStates, visiblePosition).x;

				subSum += state * weight;
			}
		}

	write_imagef(hiddenSummationTempFront, hiddenPosition, (float4)(sum + subSum));
}

void kernel cscActivateIgnoreMiddle(read_only image2d_t visibleStates,
	read_only image2d_t hiddenSummationTempBack, write_only image2d_t hiddenSummationTempFront, read_only image3d_t weights,
	int2 visibleSize, float2 hiddenToVisible, int radius)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float sum = read_imagef(hiddenSummationTempBack, hiddenPosition).x;

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float subSum = 0.0f;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			if (dx == 0 && dy == 0)
				continue;

			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float state = read_imagef(visibleStates, visiblePosition).x;

				subSum += state * weight;
			}
		}

	write_imagef(hiddenSummationTempFront, hiddenPosition, (float4)(sum + subSum));
}

void kernel cscSolveHidden(read_only image2d_t hiddenActivationSummationTemp, read_only image2d_t hiddenPredictionSummationTemp,
	write_only image2d_t hiddenStatesFront,
	int2 hiddenSize, int radius, float activeRatio)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	
	float activation = read_imagef(hiddenActivationSummationTemp, hiddenPosition).x;

	float inhibition = 0.0f;

	float counter = 0.0f;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			if (dx == 0 && dy == 0)
				continue;
			
			int2 otherPosition = hiddenPosition + (int2)(dx, dy);

			if (inBounds0(otherPosition, hiddenSize)) {
				float otherActivation = read_imagef(hiddenActivationSummationTemp, otherPosition).x;

				inhibition += otherActivation >= activation ? 1.0f : 0.0f;

				counter++;
			}
		}

	float prediction = read_imagef(hiddenPredictionSummationTemp, hiddenPosition).x;

	float binaryPred = prediction > 0.5f ? 1.0f : 0.0f;

	float state = inhibition < (counter * activeRatio) ? (1.0f - binaryPred) : 0.0f;

	write_imagef(hiddenStatesFront, hiddenPosition, (float4)(state));
}

void kernel cscLearnHiddenBiases(read_only image2d_t biasesBack, write_only image2d_t biasesFront,
	read_only image2d_t hiddenStates,
	float alpha, float activeRatio)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	
	float biasPrev = read_imagef(biasesBack, hiddenPosition).x;

	float state = read_imagef(hiddenStates, hiddenPosition).x;

	float bias = biasPrev + alpha * (activeRatio - state);

	write_imagef(biasesFront, hiddenPosition, (float4)(bias));
}

void kernel cscLearnHiddenWeightsActivation(read_only image2d_t visibleStates,
	read_only image2d_t hiddenStates, read_only image2d_t hiddenActivations,
	read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float weightAlpha)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float state = read_imagef(hiddenStates, hiddenPosition).x;
	float activation = read_imagef(hiddenActivations, hiddenPosition).x;
	
	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float visibleState = read_imagef(visibleStates, visiblePosition).x;
			
				float weight = weightPrev + weightAlpha * state * (visibleState - state * weightPrev);
	
				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight));
			}
		}
}

void kernel cscLearnHiddenWeightsTracesActivation(read_only image2d_t rewards, read_only image2d_t visibleStates,
	read_only image2d_t hiddenStates, read_only image2d_t hiddenActivations,
	read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float weightAlpha, float weightLambda)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float reward = read_imagef(rewards, hiddenPosition).x;

	float state = read_imagef(hiddenStates, hiddenPosition).x;
	float activation = read_imagef(hiddenActivations, hiddenPosition).x;
	
	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).xy;
				
				float visibleState = read_imagef(visibleStates, visiblePosition).x;
	
				float2 weight = (float2)(weightPrev.x + reward * weightPrev.y, weightPrev.y * weightLambda + weightAlpha * state * (visibleState - state * weightPrev.x));
	
				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight, 0.0f, 0.0f));
			}
		}
}

void kernel cscLearnHiddenWeightsPrediction(read_only image2d_t visibleStates,
	read_only image2d_t hiddenStates, read_only image2d_t hiddenPredictions, 
	read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float weightAlpha)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float state = read_imagef(hiddenStates, hiddenPosition).x;
	float prediction = read_imagef(hiddenPredictions, hiddenPosition).x;

	float error = state - (prediction > 0.5f ? 1.0f : 0.0f);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float visibleState = read_imagef(visibleStates, visiblePosition).x;
			
				float weight = weightPrev + weightAlpha * error * visibleState;
	
				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight));
			}
		}
}

void kernel cscLearnHiddenWeightsTracesPrediction(read_only image2d_t rewards, read_only image2d_t visibleStates,
	read_only image2d_t hiddenStates, read_only image2d_t hiddenPredictions,  
	read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float weightAlpha, float weightLambda)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float reward = read_imagef(rewards, hiddenPosition).x;

	float state = read_imagef(hiddenStates, hiddenPosition).x;
	float prediction = read_imagef(hiddenPredictions, hiddenPosition).x;

	float error = state - (prediction > 0.5f ? 1.0f : 0.0f);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).xy;
				
				float visibleState = read_imagef(visibleStates, visiblePosition).x;
	
				float2 weight = (float2)(weightPrev.x + reward * weightPrev.y, weightPrev.y * weightLambda + weightAlpha * error * visibleState);
	
				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight, 0.0f, 0.0f));
			}
		}
}

void kernel cscForward(read_only image2d_t hiddenStates,
	write_only image2d_t reconstruction, read_only image3d_t weights,
	int2 visibleSize, int2 hiddenSize, float2 visibleToHidden, float2 hiddenToVisible, int radius, int2 reverseRadii)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float recon = 0.0f;

	for (int dx = -reverseRadii.x; dx <= reverseRadii.x; dx++)
		for (int dy = -reverseRadii.y; dy <= reverseRadii.y; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(hiddenPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(visiblePosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = visiblePosition - fieldLowerBound;

					float hiddenState = read_imagef(hiddenStates, hiddenPosition).x;

					int wi = offset.y + offset.x * (radius * 2 + 1);

					float weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;
				
					recon += hiddenState * weight;
				}
			}
		}

	write_imagef(reconstruction, visiblePosition, (float4)(recon));
}

// ----------------------------------------- Sparse Coder -----------------------------------------

void kernel scReconstructVisibleError(read_only image2d_t hiddenStates, read_only image2d_t visibleStates,
	write_only image2d_t reconstructionError, read_only image3d_t weights,
	int2 visibleSize, int2 hiddenSize, float2 visibleToHidden, float2 hiddenToVisible, int radius, int2 reverseRadii)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float recon = 0.0f;

	for (int dx = -reverseRadii.x; dx <= reverseRadii.x; dx++)
		for (int dy = -reverseRadii.y; dy <= reverseRadii.y; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(hiddenPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(visiblePosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = visiblePosition - fieldLowerBound;

					float hiddenState = read_imagef(hiddenStates, hiddenPosition).x;

					int wi = offset.y + offset.x * (radius * 2 + 1);

					float weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;
				
					recon += hiddenState * weight;
				}
			}
		}

	float state = read_imagef(visibleStates, visiblePosition).x;

	float error = state - recon;

	write_imagef(reconstructionError, visiblePosition, (float4)(error));
}

void kernel scReconstructVisible(read_only image2d_t hiddenStates,
	write_only image2d_t reconstruction, read_only image3d_t weights,
	int2 visibleSize, int2 hiddenSize, float2 visibleToHidden, float2 hiddenToVisible, int radius, int2 reverseRadii)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float recon = 0.0f;

	for (int dx = -reverseRadii.x; dx <= reverseRadii.x; dx++)
		for (int dy = -reverseRadii.y; dy <= reverseRadii.y; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(hiddenPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(visiblePosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = visiblePosition - fieldLowerBound;

					float hiddenState = read_imagef(hiddenStates, hiddenPosition).x;

					int wi = offset.y + offset.x * (radius * 2 + 1);

					float weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;
				
					recon += hiddenState * weight;
				}
			}
		}

	write_imagef(reconstruction, visiblePosition, (float4)(recon));
}

void kernel scActivate(read_only image2d_t visibleStates,
	read_only image2d_t hiddenSummationTempBack, write_only image2d_t hiddenSummationTempFront, read_only image3d_t weights,
	int2 visibleSize, float2 hiddenToVisible, int radius)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float sum = read_imagef(hiddenSummationTempBack, hiddenPosition).x;

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float state = read_imagef(visibleStates, visiblePosition).x;

				sum += weight * state;
			}
		}

	write_imagef(hiddenSummationTempFront, hiddenPosition, (float4)(sum));
}

void kernel scSolveHidden(read_only image2d_t hiddenSummationTemp,
	read_only image2d_t hiddenSpikesBack, write_only image2d_t hiddenSpikesFront, 
	read_only image2d_t hiddenStatesBack, write_only image2d_t hiddenStatesFront, 
	read_only image2d_t hiddenActivationsBack, write_only image2d_t hiddenActivationsFront, 
	read_only image2d_t hiddenThresholds, read_only image3d_t weightsLateral,
	int2 hiddenSize, int radius, float leak, float accum) 
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	
	float excitation = read_imagef(hiddenSummationTemp, hiddenPosition).x;

	float statePrev = read_imagef(hiddenStatesBack, hiddenPosition).x;

	int2 fieldLowerBound = hiddenPosition - (int2)(radius);

	float inhibition = 0.0f;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			if (dx == 0 && dy == 0)
				continue;
			
			int2 otherPosition = hiddenPosition + (int2)(dx, dy);

			if (inBounds0(otherPosition, hiddenSize)) {
				int2 offset = otherPosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weight = read_imagef(weightsLateral, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float otherSpike = read_imagef(hiddenSpikesBack, otherPosition).x;

				inhibition += weight * otherSpike;
			}
		}

	float activation = read_imagef(hiddenActivationsBack, hiddenPosition).x;

	activation = (1.0f - leak) * activation + excitation - inhibition;

	float spike = 0.0f;

	float threshold = read_imagef(hiddenThresholds, hiddenPosition).x;

	if (activation > threshold) {
		spike = 1.0f;

		activation = 0.0f;
	}

	float state = spike;//(1.0f - accum) * statePrev + accum * spike;

	write_imagef(hiddenSpikesFront, hiddenPosition, (float4)(spike));
	write_imagef(hiddenStatesFront, hiddenPosition, (float4)(state));
	write_imagef(hiddenActivationsFront, hiddenPosition, (float4)(activation));
}

void kernel scLearnThresholds(read_only image2d_t hiddenThresholdsBack, write_only image2d_t hiddenThresholdsFront,
	read_only image2d_t hiddenStates,
	float thresholdAlpha, float activeRatio)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	
	float thresholdPrev = read_imagef(hiddenThresholdsBack, hiddenPosition).x;

	float hiddenState = read_imagef(hiddenStates, hiddenPosition).x;

	float threshold = thresholdPrev + thresholdAlpha * ((hiddenState == 0.0f ? 0.0f : 1.0f) - activeRatio);

	write_imagef(hiddenThresholdsFront, hiddenPosition, (float4)(threshold));
}

void kernel scLearnSparseCoderWeights(read_only image2d_t visibleStates,
	read_only image2d_t hiddenStates, read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float weightAlpha)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float state = read_imagef(hiddenStates, hiddenPosition).x;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float visibleState = read_imagef(visibleStates, visiblePosition).x;

				float weight = weightPrev + weightAlpha * state * (visibleState - state * weightPrev);

				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight));
			}
		}
}

void kernel scLearnSparseCoderWeightsTraces(read_only image2d_t visibleStates,
	read_only image2d_t hiddenStates, read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	read_only image2d_t rewards,
	int2 visibleSize, float2 hiddenToVisible, int radius, float weightAlpha, float weightTraceLambda)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float state = read_imagef(hiddenStates, hiddenPosition).x;

	float reward = read_imagef(rewards, hiddenPosition).x;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).xy;

				float visibleState = read_imagef(visibleStates, visiblePosition).x;

				float2 weight = (float2)(weightPrev.x + reward * weightPrev.y, weightPrev.y * weightTraceLambda + weightAlpha * state * (visibleState - state * weightPrev.x));

				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight, 0.0f, 0.0f));
			}
		}
}

void kernel scLearnSparseCoderWeightsLateral(read_only image2d_t hiddenStates,
	read_only image3d_t weightsLateralBack, write_only image3d_t weightsLateralFront,
	int2 hiddenSize, int radius, float weightLateralAlpha, float activeRatioSquared)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	
	int2 fieldLowerBound = hiddenPosition - (int2)(radius);

	float state = read_imagef(hiddenStates, hiddenPosition).x;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 otherPosition = hiddenPosition + (int2)(dx, dy);

			if (inBounds0(otherPosition, hiddenSize)) {
				int2 offset = otherPosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weightPrev = read_imagef(weightsLateralBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float otherState = read_imagef(hiddenStates, otherPosition).x;

				float weight = fmax(0.0f, weightPrev + weightLateralAlpha * ((state == 0.0f ? 0.0f : 1.0f) * (otherState == 0.0f ? 0.0f : 1.0f) - activeRatioSquared));

				write_imagef(weightsLateralFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight));
			}
		}
}

// ----------------------------------------- Predictor -----------------------------------------

void kernel predActivate(read_only image2d_t visibleStates,
	read_only image2d_t hiddenSummationTempBack, write_only image2d_t hiddenSummationTempFront, read_only image3d_t weights,
	int2 visibleSize, float2 hiddenToVisible, int radius)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float sum = read_imagef(hiddenSummationTempBack, hiddenPosition).x;

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float subSum = 0.0f;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float state = read_imagef(visibleStates, visiblePosition).x;

				subSum += weight * state;
			}
		}

	write_imagef(hiddenSummationTempFront, hiddenPosition, (float4)(sum + subSum));
}

void kernel predSolveHiddenBinary(read_only image2d_t hiddenSummationTemp,
	write_only image2d_t hiddenStatesFront) 
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	
	float sum = read_imagef(hiddenSummationTemp, hiddenPosition).x;

	write_imagef(hiddenStatesFront, hiddenPosition, (float4)(sum > 0.5f ? 1.0f : 0.0f));
}

void kernel predSolveHiddenTanH(read_only image2d_t hiddenSummationTemp,
	write_only image2d_t hiddenStatesFront) 
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	
	float sum = read_imagef(hiddenSummationTemp, hiddenPosition).x;

	write_imagef(hiddenStatesFront, hiddenPosition, (float4)(tanh(sum)));
}

void kernel predLearnWeights(read_only image2d_t visibleStatesPrev, 
	read_only image2d_t targets, read_only image2d_t predictionsPrev, read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float weightAlpha)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);
	
	float target = read_imagef(targets, hiddenPosition).x;
	float predPrev = read_imagef(predictionsPrev, hiddenPosition).x;

	float alphaError = weightAlpha * (target - predPrev);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float state = read_imagef(visibleStatesPrev, visiblePosition).x;

				float weight = weightPrev + alphaError * state;

				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight));
			}
		}
}

void kernel predLearnWeightsTraces(read_only image2d_t visibleStatesPrev, 
	read_only image2d_t targets, read_only image2d_t predictionsPrev, read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float weightAlpha, float weightLambda, float tdError)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);
	
	float target = read_imagef(targets, hiddenPosition).x;
	float predPrev = read_imagef(predictionsPrev, hiddenPosition).x;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).xy;

				float statePrev = read_imagef(visibleStatesPrev, visiblePosition).x;

				float newTrace = weightPrev.y * weightLambda + (target - predPrev) * statePrev;
	
				float2 weight = (float2)(weightPrev.x + weightAlpha * (fmax(0.0f, tdError) * newTrace), newTrace);

				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight, 0.0f, 0.0f));
			}
		}
}

void kernel predLearnQWeightsTraces(read_only image2d_t visibleStatesPrev, 
	read_only image2d_t predictionsPrev, read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float weightAlpha, float weightLambda, float tdError)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float alphaError = weightAlpha;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).xy;

				float state = read_imagef(visibleStatesPrev, visiblePosition).x;

				float newTrace = weightPrev.y * weightLambda + alphaError * state;

				float2 weight = (float2)(weightPrev.x + tdError * newTrace, newTrace);

				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight, 0.0f, 0.0f));
			}
		}
}

// ----------------------------------------- Predictor Swarm -----------------------------------------

void kernel predErrorPropagateSwarm(read_only image2d_t targets, read_only image2d_t hiddenStatesPrev,
	write_only image2d_t errors, read_only image3d_t weights,
	int2 visibleSize, int2 hiddenSize, float2 visibleToHidden, float2 hiddenToVisible, int radius, int2 reverseRadii)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float error = 0.0f;

	for (int dx = -reverseRadii.x; dx <= reverseRadii.x; dx++)
		for (int dy = -reverseRadii.y; dy <= reverseRadii.y; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(hiddenPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(visiblePosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = visiblePosition - fieldLowerBound;

					float predError = read_imagef(targets, hiddenPosition).x - read_imagef(hiddenStatesPrev, hiddenPosition).x;

					int wi = offset.y + offset.x * (radius * 2 + 1);

					float weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;
				
					error += predError * weight;
				}
			}
		}

	write_imagef(errors, visiblePosition, (float4)(error));
}

void kernel predActivateSwarm(read_only image2d_t visibleStates,
	read_only image2d_t hiddenSummationTempBack, write_only image2d_t hiddenSummationTempFront, read_only image3d_t weights,
	int2 visibleSize, float2 hiddenToVisible, int radius)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float2 sum = read_imagef(hiddenSummationTempBack, hiddenPosition).xy;

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).xz;

				float state = read_imagef(visibleStates, visiblePosition).x;

				sum += weight * state;
			}
		}

	write_imagef(hiddenSummationTempFront, hiddenPosition, (float4)(sum, 0.0f, 0.0f));
}

void kernel predLearnBiasesSwarm(read_only image2d_t hiddenStates, read_only image2d_t hiddenBiasesBack, write_only image2d_t hiddenBiasesFront,
	float alpha, float activeRatio)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));

	float state = read_imagef(hiddenStates, hiddenPosition).x;

	float biasPrev = read_imagef(hiddenBiasesBack, hiddenPosition).x;

	float bias = biasPrev + alpha * (activeRatio - state);

	write_imagef(hiddenBiasesFront, hiddenPosition, (float4)(bias, 0.0f, 0.0f, 0.0f));
}

void kernel predLearnWeightsTracesSwarm(read_only image2d_t visibleStatesPrev, read_only image2d_t targets,
	read_only image2d_t predictionStates, read_only image2d_t predictionActivationsPrev, read_only image2d_t predictionStatesPrev,
	read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	read_only image3d_t qTracesBack, write_only image3d_t qTracesFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float2 weightAlpha, float2 weightLambda,
	float reward, float gamma, float activeRatio, float noise)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);
	
	float target = read_imagef(targets, hiddenPosition).x;
	float2 state = read_imagef(predictionStates, hiddenPosition).xy;
	float predActPrev = read_imagef(predictionActivationsPrev, hiddenPosition).x;
	float2 predPrev = read_imagef(predictionStatesPrev, hiddenPosition).xy;

	float predError = target - predPrev.x;

	float tdError = reward + gamma * state.y - predPrev.y;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float4 weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0));
				float qTracePrev = read_imagef(qTracesBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float statePrev = read_imagef(visibleStatesPrev, visiblePosition).x;

				//float clear = 1.0f - statePrev;

				float newYTrace = weightPrev.y * weightLambda.x + predError * statePrev;
				float newWTrace = weightPrev.w * weightLambda.x + 0.0f;//predPrev.x * statePrev; // Reversal trace
				float newQTrace = qTracePrev * weightLambda.y + statePrev;

				float change = tdError * newYTrace;

				float4 weight = (float4)(fmin(1.0f, fmax(-1.0f, weightPrev.x + weightAlpha.x * tdError * newYTrace)), newYTrace,
						weightPrev.z + weightAlpha.y * tdError * newQTrace, newWTrace);

				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), weight);
				write_imagef(qTracesFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(newQTrace));
			}
		}
}

void kernel predSolveHiddenSwarm(read_only image2d_t sums,
	write_only image2d_t states, write_only image2d_t activations,
	int2 size, int radius, float activeRatio)
{
	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float2 sum = read_imagef(sums, position).xy;

	float inhibition = 0.0f;

	float counter = 0.0f;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			if (dx == 0 && dy == 0)
				continue;
			
			int2 otherPosition = position + (int2)(dx, dy);

			if (inBounds0(otherPosition, size)) {
				float otherSum = read_imagef(sums, otherPosition).x;

				inhibition += otherSum >= sum.x ? 1.0f : 0.0f;

				counter++;
			}
		}

	float state = inhibition < (counter * activeRatio) ? 1.0f : 0.0f;

	write_imagef(states, position, (float4)(state, sum.y, 0.0f, 0.0f));
	write_imagef(activations, position, (float4)(sum.x, sum.y, 0.0f, 0.0f));
}

void kernel predSolveHiddenNoInhibitionSwarm(read_only image2d_t sums,
	write_only image2d_t states, write_only image2d_t activations)
{
	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float2 sum = read_imagef(sums, position).xy;

	float state = sigmoid(sum.x);

	write_imagef(states, position, (float4)(state, sum.y, 0.0f, 0.0f));
	write_imagef(activations, position, (float4)(sum.x, sum.y, 0.0f, 0.0f));
}

void kernel predReconstructionErrorSwarm(read_only image2d_t hiddenStates, read_only image2d_t visibleStatesPrev,
	write_only image2d_t reconstructionError, read_only image3d_t weights,
	int2 visibleSize, int2 hiddenSize, float2 visibleToHidden, float2 hiddenToVisible, int radius, int2 reverseRadii)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float recon = 0.0f;

	for (int dx = -reverseRadii.x; dx <= reverseRadii.x; dx++)
		for (int dy = -reverseRadii.y; dy <= reverseRadii.y; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(hiddenPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(visiblePosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = visiblePosition - fieldLowerBound;

					float hiddenState = read_imagef(hiddenStates, hiddenPosition).x;
		
					int wi = offset.y + offset.x * (radius * 2 + 1);

					float weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;
				
					recon += hiddenState * weight;
				}
			}
		}

	float state = read_imagef(visibleStatesPrev, visiblePosition).x;

	float error = state - recon;

	write_imagef(reconstructionError, visiblePosition, (float4)(error));
}

// ----------------------------------------- Predictor Swarm -----------------------------------------

void kernel swarmQPropagateToHiddenError(read_only image3d_t weights, write_only image2d_t hiddenErrors,
	int2 qSize, int2 hiddenSize, float2 qToHidden, float2 hiddenToQ, int radius, int2 reverseQRadii)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 qPositionCenter = (int2)(hiddenPosition.x * hiddenToQ.x + 0.5f, hiddenPosition.y * hiddenToQ.y + 0.5f);
	
	float2 error = (float2)(0.0f);

	for (int dx = -reverseQRadii.x; dx <= reverseQRadii.x; dx++)
		for (int dy = -reverseQRadii.y; dy <= reverseQRadii.y; dy++) {
			int2 qPosition = qPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(qPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(qPosition.x * qToHidden.x + 0.5f, qPosition.y * qToHidden.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(hiddenPosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = hiddenPosition - fieldLowerBound;

					//float qState = read_imagef(qStates, qPosition).x;

					int wi = offset.y + offset.x * (radius * 2 + 1);

					float2 weight = read_imagef(weights, (int4)(qPosition.x, qPosition.y, wi, 0)).xz;
				
					error += weight;
				}
			}
		}

	write_imagef(hiddenErrors, hiddenPosition, (float4)(error.x, error.y, 0.0f, 0.0f));
}

void kernel swarmQPropagateToHiddenTD(read_only image2d_t qStates, read_only image2d_t qStatesPrev, 
	write_only image2d_t hiddenTDErrors,
	int2 qSize, int2 hiddenSize, float2 qToHidden, float2 hiddenToQ, int radius, int2 reverseQRadii,
	float reward, float gamma)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 qPositionCenter = (int2)(hiddenPosition.x * hiddenToQ.x + 0.5f, hiddenPosition.y * hiddenToQ.y + 0.5f);
	
	float sum = 0.0f;
	float div = 0.0f;

	for (int dx = -reverseQRadii.x; dx <= reverseQRadii.x; dx++)
		for (int dy = -reverseQRadii.y; dy <= reverseQRadii.y; dy++) {
			int2 qPosition = qPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(qPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(qPosition.x * qToHidden.x + 0.5f, qPosition.y * qToHidden.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(hiddenPosition, fieldLowerBound, fieldUpperBound)) {	
					float qState = read_imagef(qStates, qPosition).x;
					float qStatePrev = read_imagef(qStatesPrev, qPosition).x;

					float tdError = reward + gamma * qState - qStatePrev;

					sum += tdError;
					div += 1.0f;
				}
			}
		}

	write_imagef(hiddenTDErrors, hiddenPosition, (float4)(sum / fmax(1.0f, div)));
}

void kernel swarmPredictAction(read_only image2d_t hiddenStatesFeedForward, read_only image2d_t actionsFeedBack,
	read_only image3d_t weights, write_only image2d_t predictedAction,
	int2 hiddenSize, float2 visibleToHidden, int radius)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float sum = 0.0f;

	int2 fieldLowerBound = hiddenPositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);

			if (inBounds0(hiddenPosition, hiddenSize)) {
				int2 offset = hiddenPosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weight = read_imagef(weights, (int4)(visiblePosition.x, visiblePosition.y, wi, 0)).xy;

				float hsff = read_imagef(hiddenStatesFeedForward, hiddenPosition).x;
				float afb = read_imagef(actionsFeedBack, hiddenPosition).x;

				sum += weight.x * hsff + weight.y * afb;
			}
		}

	write_imagef(predictedAction, visiblePosition, (float4)(tanh(sum)));
}

void kernel swarmInitSummation(read_only image2d_t hiddenBiases, write_only image2d_t hiddenSummationTempFront) {
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	
	float2 biases = read_imagef(hiddenBiases, hiddenPosition).xz;
	
	write_imagef(hiddenSummationTempFront, hiddenPosition, (float4)(biases.x, biases.y, 0.0f, 0.0f));
}

void kernel swarmQActivateToHidden(read_only image2d_t visibleStates,
	read_only image2d_t hiddenSummationTempBack, write_only image2d_t hiddenSummationTempFront, read_only image3d_t weights,
	int2 visibleSize, float2 hiddenToVisible, int radius)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float2 sum = read_imagef(hiddenSummationTempBack, hiddenPosition).xy;

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).xz;

				float state = read_imagef(visibleStates, visiblePosition).x;

				sum += weight * state;
			}
		}

	write_imagef(hiddenSummationTempFront, hiddenPosition, (float4)(sum.x, sum.y, 0.0f, 0.0f));
}

void kernel swarmQSolveHidden(read_only image2d_t hiddenSummationTemp,
	read_only image2d_t hiddenStatesFeedForward, read_only image2d_t actionsFeedBack,
	write_only image2d_t hiddenStates) 
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	
	float2 sum = read_imagef(hiddenSummationTemp, hiddenPosition).xy;

	float hsff = read_imagef(hiddenStatesFeedForward, hiddenPosition).x;
	float afb = read_imagef(actionsFeedBack, hiddenPosition).x;

	write_imagef(hiddenStates, hiddenPosition, (float4)(tanh(sum.x) * hsff, tanh(sum.y) * afb, 0.0f, 0.0f));
}

void kernel swarmHiddenPropagateToVisibleAction(read_only image2d_t hiddenErrors, read_only image2d_t hiddenStates,
	read_only image3d_t weights, read_only image2d_t actionsBack, write_only image2d_t actionsFront,
	int2 hiddenSize, int2 visibleSize, float2 hiddenToVisible, float2 visibleToHidden, int radius, int2 reverseRadii,
	float actionAlpha)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float error = 0.0f;

	for (int dx = -reverseRadii.x; dx <= reverseRadii.x; dx++)
		for (int dy = -reverseRadii.y; dy <= reverseRadii.y; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(hiddenPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(visiblePosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = visiblePosition - fieldLowerBound;

					float2 hiddenState = read_imagef(hiddenStates, hiddenPosition).xy;
					float2 hiddenError = read_imagef(hiddenErrors, hiddenPosition).xy;

					int wi = offset.y + offset.x * (radius * 2 + 1);

					float2 weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).xz;
				
					error += dot((1.0f - hiddenState * hiddenState) * hiddenError, weight);
				}
			}
		}

	float prevAction = read_imagef(actionsBack, visiblePosition).x;

	float nextAction = fmin(1.0f, fmax(-1.0f, prevAction + actionAlpha * (error > 0.0f ? 1.0f : -1.0f)));

	write_imagef(actionsFront, visiblePosition, (float4)(nextAction));
}

void kernel swarmExploration(read_only image2d_t actions,
	write_only image2d_t actionsExploratory, float expPert, float expBreak, uint2 seed)  
{
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 45 + 25, get_global_id(1) * 56 + 24) * 6;

	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float action = read_imagef(actions, position).x;
	
	write_imagef(actionsExploratory, position, (float4)(randFloat(&seedValue) < expBreak ? randFloat(&seedValue) * 2.0f - 1.0f : fmin(1.0f, fmax(0.0f, action + expPert * randNormal(&seedValue)))));
}

void kernel swarmQActivateToQ(read_only image2d_t hiddenStates,
	read_only image3d_t weights, write_only image2d_t qStates,
	int2 hiddenSize, float2 qToHidden, int radius)
{
	int2 qPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(qPosition.x * qToHidden.x + 0.5f, qPosition.y * qToHidden.y + 0.5f);
	
	float sum = 0.0f;

	int2 fieldLowerBound = hiddenPositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);

			if (inBounds0(hiddenPosition, hiddenSize)) {
				int2 offset = hiddenPosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weight = read_imagef(weights, (int4)(qPosition.x, qPosition.y, wi, 0)).xy;

				float2 state = read_imagef(hiddenStates, hiddenPosition).xy;

				sum += dot(weight, state);
			}
		}

	write_imagef(qStates, qPosition, (float4)(sum));
}

void kernel swarmQLearnVisibleWeightsTraces(read_only image2d_t actionsExploratory, 
	read_only image2d_t hiddenErrors, read_only image2d_t hiddenTD, read_only image2d_t hiddenStates,
	read_only image3d_t weightsBack, write_only image3d_t weightsFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float alpha, float lambda)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);
	
	float tdError = read_imagef(hiddenTD, hiddenPosition).x;

	float2 hiddenState = read_imagef(hiddenStates, hiddenPosition).xy;

	float2 hiddenError = read_imagef(hiddenErrors, hiddenPosition).xy;

	float2 error = hiddenError * (1.0f - hiddenState * hiddenState);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float4 weightPrev = read_imagef(weightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0));

				float state = read_imagef(actionsExploratory, visiblePosition).x;

				float4 weight = (float4)(weightPrev.x + tdError * weightPrev.y, lambda * weightPrev.y + alpha * error.x * state,
						weightPrev.z + tdError * weightPrev.w, lambda * weightPrev.w + alpha * error.y * state);

				write_imagef(weightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), weight);
			}
		}
}

void kernel swarmStartLearnWeights(read_only image2d_t actions, read_only image2d_t predictedAction,
	read_only image2d_t hiddenStatesFeedForward, read_only image2d_t actionsFeedBack,
	read_only image3d_t weightsPrev, write_only image3d_t weights,
	int2 hiddenSize, float2 visibleToHidden, int radius,
	float alpha)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float alphaError = alpha * (read_imagef(actions, visiblePosition).x - read_imagef(predictedAction, visiblePosition).x);

	int2 fieldLowerBound = hiddenPositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);

			if (inBounds0(hiddenPosition, hiddenSize)) {
				int2 offset = hiddenPosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weightPrev = read_imagef(weightsPrev, (int4)(visiblePosition.x, visiblePosition.y, wi, 0)).xy;

				float hsff = read_imagef(hiddenStatesFeedForward, hiddenPosition).x;
				float afb = read_imagef(actionsFeedBack, hiddenPosition).x;

				float2 weight = weightPrev + alphaError * (float2)(hsff, afb);
				
				write_imagef(weights, (int4)(visiblePosition.x, visiblePosition.y, wi, 0), (float4)(weight, 0.0f, 0.0f));
			}
		}
}

void kernel swarmQLearnHiddenWeightsTraces(read_only image2d_t hiddenStates,
	read_only image2d_t qStates, read_only image2d_t qStatesPrev,
	read_only image3d_t weightsPrev, write_only image3d_t weights,
	int2 hiddenSize, float2 qToHidden, int radius,
	float alpha, float lambda, float reward, float gamma)
{
	int2 qPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(qPosition.x * qToHidden.x + 0.5f, qPosition.y * qToHidden.y + 0.5f);
	
	float qState = read_imagef(qStates, qPosition).x;
	float qStatePrev = read_imagef(qStatesPrev, qPosition).x;

	float tdError = reward + gamma * qState - qStatePrev;

	int2 fieldLowerBound = hiddenPositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);

			if (inBounds0(hiddenPosition, hiddenSize)) {
				int2 offset = hiddenPosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float4 weightPrev = read_imagef(weightsPrev, (int4)(qPosition.x, qPosition.y, wi, 0));

				float2 state = read_imagef(hiddenStates, hiddenPosition).xy;

				float4 weight = (float4)(weightPrev.x + tdError * weightPrev.y, weightPrev.y * lambda + alpha * state.x,
					weightPrev.z + tdError * weightPrev.w, weightPrev.w * lambda + alpha * state.y);
				
				write_imagef(weights, (int4)(qPosition.x, qPosition.y, wi, 0), weight);
			}
		}
}

void kernel swarmQLearnHiddenBiasesTraces(read_only image2d_t hiddenTD, read_only image2d_t hiddenErrors,
	read_only image2d_t biasesBack, write_only image2d_t biasesFront,
	float alpha, float lambda)  
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));

	float4 biasPrev = read_imagef(biasesBack, hiddenPosition);

	float tdError = read_imagef(hiddenTD, hiddenPosition).x;

	float2 error = read_imagef(hiddenErrors, hiddenPosition).xy;

	float4 bias = (float4)(biasPrev.x + tdError * biasPrev.y, biasPrev.y * lambda + alpha * error.x,
		biasPrev.z + tdError * biasPrev.w, biasPrev.w * lambda + alpha * error.y);
				
	write_imagef(biasesFront, hiddenPosition, bias);
}

// ----------------------------------------- Predictive Hierarchy -----------------------------------------

void kernel phPredictionReward(read_only image2d_t predictions, read_only image2d_t hiddenStates,
	write_only image2d_t rewards, read_only image2d_t hiddenBaselinesBack, write_only image2d_t hiddenBaselinesFront, float activeRatio, float baselineDecay)
{
	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float pred = read_imagef(predictions, position).x;

	float state = read_imagef(hiddenStates, position).x;

	float reward = pred * state;// + (1.0f - pred) * (1.0f - state) * activeRatio);

	float baselinePrev = read_imagef(hiddenBaselinesBack, position).x;

	float baseline = (1.0f - baselineDecay) * baselinePrev + baselineDecay * reward;

	write_imagef(hiddenBaselinesFront, position, (float4)(baseline));
	write_imagef(rewards, position, (float4)(fmax(0.0f, reward - baselinePrev)));
}

void kernel phPredictionRewardPropagation(read_only image2d_t rewards, write_only image2d_t propagatedRewards,
	float2 hiddenToVisible, int2 visibleSize, int radius)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float total = 0.0f;
	float count = 0.0f;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				//int2 offset = visiblePosition - fieldLowerBound;

				//int wi = offset.y + offset.x * (radius * 2 + 1);

				float reward = read_imagef(rewards, visiblePosition).x;

				total += reward;

				count++;
			}
		}

	write_imagef(propagatedRewards, hiddenPosition, (float4)(total / fmax(1.0f, count)));
}

void kernel phModulate(read_only image2d_t inputsLeft, read_only image2d_t inputsRight,
	write_only image2d_t states, float minAttention)
{
	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float left = read_imagef(inputsLeft, position).x;
	float right = read_imagef(inputsRight, position).x;

	write_imagef(states, position, (float4)(left * (minAttention + (1.0f - minAttention) * right)));
}

void kernel phCopyAction(read_only image2d_t source, write_only image2d_t destination) {
	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float s = read_imagef(source, position).x;
	
	write_imagef(destination, position, (float4)(s));
}

void kernel phExploration(read_only image2d_t actions,
	write_only image2d_t actionsExploratory, float expPert, float expBreak, uint2 seed)  
{
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 45 + 25, get_global_id(1) * 56 + 24) * 6;

	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float action = read_imagef(actions, position).x;
	
	write_imagef(actionsExploratory, position, (float4)(randFloat(&seedValue) < expBreak ? randFloat(&seedValue) * 2.0f - 1.0f : fmin(1.0f, fmax(-1.0f, action + expPert * randNormal(&seedValue)))));
}

void kernel phSetQ(read_only image2d_t qTransforms, write_only image2d_t qValues, float q) {
	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float3 trans = read_imagef(qTransforms, position).xyz;
	
	float wQ = q * q * trans.x + q * trans.y + trans.z;

	write_imagef(qValues, position, (float4)(wQ));
}

void kernel phGetQ(read_only image2d_t qPreds, read_only image2d_t qTransforms, write_only image2d_t qValues) {
	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float pred = read_imagef(qPreds, position).x;
	
	float2 trans = read_imagef(qTransforms, position).xy;
	
	float wQ = (pred - trans.y) / (trans.x == 0.0f ? 1.0f : trans.x);

	write_imagef(qValues, position, (float4)(wQ));
}

// ----------------------------------------- Q Route -----------------------------------------

void kernel qForward(read_only image2d_t hiddenStates, read_only image3d_t qWeights, read_only image2d_t qBiases, read_only image2d_t qStatesPrev, write_only image2d_t qStatesFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float reluLeak)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float sum = read_imagef(qBiases, hiddenPosition).x;

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weight = read_imagef(qWeights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float state = read_imagef(qStatesPrev, visiblePosition).x;

				sum += weight * state;
			}
		}

	float hiddenState = read_imagef(hiddenStates, hiddenPosition).x;

	float state = sigmoid(sum) * hiddenState;
	
	write_imagef(qStatesFront, hiddenPosition, (float4)(state));
}

void kernel qLastForward(read_only image3d_t qWeights, read_only image2d_t qBiases, read_only image2d_t qStatesPrev, write_only image2d_t qStatesFront,
	int2 visibleSize, float2 hiddenToVisible, int radius)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float sum = 0.0f;//read_imagef(qBiases, hiddenPosition).x;

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weight = read_imagef(qWeights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float state = read_imagef(qStatesPrev, visiblePosition).x;

				sum += weight * state;
			}
		}

	write_imagef(qStatesFront, hiddenPosition, (float4)(sum));
}

void kernel qBackward(read_only image2d_t hiddenStates, read_only image2d_t qStates, read_only image3d_t qWeights, read_only image2d_t qErrorsNext, write_only image2d_t qErrors,
	int2 visibleSize, int2 hiddenSize, float2 visibleToHidden, float2 hiddenToVisible, int radius, int2 reverseRadii, float reluLeak)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float sum = 0.0f;

	for (int dx = -reverseRadii.x; dx <= reverseRadii.x; dx++)
		for (int dy = -reverseRadii.y; dy <= reverseRadii.y; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(hiddenPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(visiblePosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = visiblePosition - fieldLowerBound;

					float errorNext = read_imagef(qErrorsNext, hiddenPosition).x;

					int wi = offset.y + offset.x * (radius * 2 + 1);

					float weight = read_imagef(qWeights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;
				
					sum += errorNext * weight;
				}
			}
		}

	sum = sum > 0.0f ? 1.0f : -1.0f;

	float qState = read_imagef(qStates, visiblePosition).x;

	float hiddenState = read_imagef(hiddenStates, visiblePosition).x;

	float error = sum * qState * (1.0f - qState);// * hiddenState;

	write_imagef(qErrors, visiblePosition, (float4)(error));
}

void kernel qLastBackward(read_only image2d_t hiddenStates, read_only image2d_t qStates, read_only image3d_t qWeights, write_only image2d_t qErrors,
	int2 visibleSize, int2 hiddenSize, float2 visibleToHidden, float2 hiddenToVisible, int radius, int2 reverseRadii, float reluLeak)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float sum = 0.0f;

	for (int dx = -reverseRadii.x; dx <= reverseRadii.x; dx++)
		for (int dy = -reverseRadii.y; dy <= reverseRadii.y; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(hiddenPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(visiblePosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = visiblePosition - fieldLowerBound;

					int wi = offset.y + offset.x * (radius * 2 + 1);

					float weight = read_imagef(qWeights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;
				
					sum += weight;
				}
			}
		}

	sum = sum > 0.0f ? 1.0f : -1.0f;

	float qState = read_imagef(qStates, visiblePosition).x;

	float hiddenState = read_imagef(hiddenStates, visiblePosition).x;

	float error = sum * qState * (1.0f - qState);// * hiddenState;

	write_imagef(qErrors, visiblePosition, (float4)(error));
}

void kernel qFirstBackward(read_only image2d_t inputStates, read_only image3d_t qWeights, read_only image2d_t qErrorsNext, write_only image2d_t qErrors,
	int2 visibleSize, int2 hiddenSize, float2 visibleToHidden, float2 hiddenToVisible, int radius, int2 reverseRadii)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	
	float inputState = read_imagef(inputStates, visiblePosition).x;

	float sum = 0.0f;

	for (int dx = -reverseRadii.x; dx <= reverseRadii.x; dx++)
		for (int dy = -reverseRadii.y; dy <= reverseRadii.y; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);
		
			if (inBounds0(hiddenPosition, hiddenSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(radius);
				int2 fieldUpperBound = fieldCenter + (int2)(radius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(visiblePosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = visiblePosition - fieldLowerBound;

					float errorNext = read_imagef(qErrorsNext, hiddenPosition).x;

					int wi = offset.y + offset.x * (radius * 2 + 1);

					float weight = read_imagef(qWeights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

					sum += errorNext * weight;
				}
			}
		}

	write_imagef(qErrors, visiblePosition, (float4)(sum));
}

void kernel qWeightUpdate(read_only image2d_t qStatesPrev, read_only image2d_t qStates, read_only image2d_t qErrors,
	read_only image3d_t qWeightsBack, write_only image3d_t qWeightsFront,
	read_only image2d_t qBiasesBack, write_only image2d_t qBiasesFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float alpha, float biasAlpha, float lambda, float tdError)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float state = read_imagef(qStates, hiddenPosition).x;

	float error = read_imagef(qErrors, hiddenPosition).x;
	
	// Bias
	float2 biasPrev = read_imagef(qBiasesBack, hiddenPosition).xy;

	//float2 bias = (float2)(biasPrev.x + alpha * tdError * biasPrev.y, biasPrev.y * lambda + error);
	float2 bias = (float2)(biasPrev.x + biasAlpha * (0.5f - state), biasPrev.y * lambda + error);

	write_imagef(qBiasesFront, hiddenPosition, (float4)(bias, 0.0f, 0.0f));

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weightPrev = read_imagef(qWeightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).xy;

				float statePrev = read_imagef(qStatesPrev, visiblePosition).x;

				float2 weight = (float2)(weightPrev.x + alpha * tdError * weightPrev.y, weightPrev.y * lambda + error * statePrev);//(statePrev - error * weightPrev.x));

				write_imagef(qWeightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight, 0.0f, 0.0f));
			}
		}
}

void kernel qLastWeightUpdate(read_only image2d_t qStatesPrev, read_only image2d_t qStates,
	read_only image3d_t qWeightsBack, write_only image3d_t qWeightsFront,
	read_only image2d_t qBiasesBack, write_only image2d_t qBiasesFront,
	int2 visibleSize, float2 hiddenToVisible, int radius, float alpha, float biasAlpha, float lambda, float tdError)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float state = read_imagef(qStates, hiddenPosition).x;

	// Bias
	float2 biasPrev = read_imagef(qBiasesBack, hiddenPosition).xy;

	//float2 bias = (float2)(biasPrev.x + alpha * tdError * biasPrev.y, biasPrev.y * lambda + 1.0f);
	float2 bias = (float2)(biasPrev.x + biasAlpha * (0.5f - state), biasPrev.y * lambda + 1.0f);

	write_imagef(qBiasesFront, hiddenPosition, (float4)(bias, 0.0f, 0.0f));

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float2 weightPrev = read_imagef(qWeightsBack, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).xy;

				float statePrev = read_imagef(qStatesPrev, visiblePosition).x;

				float2 weight = (float2)(weightPrev.x + alpha * tdError * weightPrev.y, weightPrev.y * lambda + statePrev);

				write_imagef(qWeightsFront, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0), (float4)(weight, 0.0f, 0.0f));
			}
		}
}

void kernel qActionUpdate(read_only image2d_t actionsPrev, read_only image2d_t errors, write_only image2d_t actions, float alpha) {
	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float actionPrev = read_imagef(actionsPrev, position).x;

	float error = read_imagef(errors, position).x;

	float action = fmin(1.0f, fmax(-1.0f, actionPrev + alpha * (error > 0.0f ? 1.0f : -1.0f)));

	write_imagef(actions, position, (float4)(action));
}

// ----------------------------------------- Preprocessing -----------------------------------------

void kernel whiten(read_only image2d_t input, write_only image2d_t result, int2 imageSize, int kernelRadius, float intensity) {
	int2 position = (int2)(get_global_id(0), get_global_id(1));
	
	float4 currentColor = read_imagef(input, position);

	float4 center = currentColor;

	float count = 0.0f;

	for (int dx = -kernelRadius; dx <= kernelRadius; dx++)
		for (int dy = -kernelRadius; dy <= kernelRadius; dy++) {
			if (dx == 0 && dy == 0)
				continue;
			
			int2 otherPosition = position + (int2)(dx, dy);

			if (inBounds0(otherPosition, imageSize)) {
				float4 otherColor = read_imagef(input, otherPosition);

				center += otherColor;

				count++;
			}
		}

	center /= count + 1.0f;

	float4 centeredCurrentColor = currentColor - center;

	float4 covariances = (float4)(0.0f);

	for (int dx = -kernelRadius; dx <= kernelRadius; dx++)
		for (int dy = -kernelRadius; dy <= kernelRadius; dy++) {
			if (dx == 0 && dy == 0)
				continue;
			
			int2 otherPosition = position + (int2)(dx, dy);

			if (inBounds0(otherPosition, imageSize)) {
				float4 otherColor = read_imagef(input, otherPosition);

				float4 centeredOtherColor = otherColor - center;

				covariances += centeredOtherColor * centeredCurrentColor;
			}
		}

	covariances /= fmax(1.0f, count);

	float4 centeredCurrentColorSigns = (float4)(centeredCurrentColor.x > 0.0f ? 1.0f : -1.0f,
		centeredCurrentColor.y > 0.0f ? 1.0f : -1.0f,
		centeredCurrentColor.z > 0.0f ? 1.0f : -1.0f,
		centeredCurrentColor.w > 0.0f ? 1.0f : -1.0f);

	// Modify color
	float4 whitenedColor = fmin(1.0f, fmax(-1.0f, (centeredCurrentColor > 0.0f ? (float4)(1.0f) : (float4)(-1.0f)) * (1.0f - exp(-fabs(intensity * covariances)))));

	write_imagef(result, position, whitenedColor);
}

