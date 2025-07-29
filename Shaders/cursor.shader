shader_type canvas_item;

uniform float zoom = 1.00;
uniform float thickness = 2.00;
uniform float custom_time = 0.0;
const float animationRate = 0.15;

void fragment() {
	float textureWidth = float(textureSize(TEXTURE,0).x);
	float textureHeight = float(textureSize(TEXTURE,0).y);
	vec2 texel = vec2(1.0/textureWidth, 1.0/textureHeight);
	
	vec4 baseCol = texture(TEXTURE, UV + (custom_time*animationRate));
	
	baseCol.a = 0.0;
	
	float superPixel = max(texel.x, texel.x*zoom)*thickness;
	
	if ( UV.x <= superPixel ) {
		baseCol.a = 1.0;
	}
	if ( UV.y <= superPixel) {
		baseCol.a = 1.0;
	}
	
	if ( UV.x >= ((texel.x * textureWidth) - superPixel )) {
		baseCol.a = 1.0;
	}
	if ( UV.y >= ((texel.y * textureHeight) - superPixel )) {
		baseCol.a = 1.0;
	}
	
    COLOR = baseCol;
}