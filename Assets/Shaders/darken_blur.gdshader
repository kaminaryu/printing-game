shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;
uniform float darkness : hint_range(0.0, 1.0) = 0.5;

uniform vec2 hole_centers[16];
uniform vec2 hole_sizes[16];
uniform int hole_count = 0;
uniform float feather : hint_range(0.0, 0.5) = 0.02;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.25;
uniform float pulse_speed : hint_range(0.0, 20.0) = 4.0;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Sample blurred screen texture
    vec4 blurred_color = textureLod(screen_texture, SCREEN_UV, blur_amount);
    blurred_color.rgb *= (1.0 - darkness);

    // Union of rectangular holes with rounded corners (box SDF)
    float mask = 1.0;
    for (int i = 0; i < hole_count; i++) {
        vec2 diff = abs(SCREEN_UV - hole_centers[i]);
        vec2 d = diff - max(hole_sizes[i], vec2(0.001));
        float dist = length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0);
        mask = min(mask, smoothstep(-feather, feather, dist));
    }

    // Pulse: the hole region periodically lets a bit of the darkened blur through
    float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5) * pulse_strength;
    float alpha = mix(mask, pulse, 1.0 - mask);

    blurred_color.a *= alpha;
    COLOR = blurred_color;
}