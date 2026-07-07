shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 1.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Sample the screen texture with a mipmap LOD to create the blur
    vec4 blurred_color = textureLod(screen_texture, SCREEN_UV, blur_amount);
    COLOR = blurred_color;
}