#version 130
in vec2 coordTexture;
uniform sampler2D text;

out vec4 out_Color;

void main(){
	out_Color = texture(text, coordTexture);
}
