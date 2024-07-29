/*
Earthbound battle backgrounds shader with scrolling effect and palette cycling like in the original game.
@retr0_dev
Link: https://godotshaders.com/shader/earthbound-like-battle-background-shader-w-scroll-effect-and-palette-cycling/

Apply the shader to a TextureRect or a Sprite. Use a texture with some shapes in a transparent background for best results.
You can then use a ColorRect or another method to paint the background.
You can use the shader on multiple TextureRects and obtain a double-buffer effect tweaking the values for each one, remember to Make Unique the shader material.
*/
shader_type canvas_item;

uniform float override_alpha: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float screen_height = 640.0;
uniform float amplitude = 0.075;
uniform float frequency = 10.0;
uniform float speed = 2.0;
uniform float amplitude_vertical = 0.0;
uniform float frequency_vertical = 0.0;
uniform float speed_vertical = 0.0;
uniform vec2 scroll_direction = vec2(0.0, 0.0);
uniform float scrolling_speed = 0.08;
uniform bool enable_palette_cycling = false;
uniform sampler2D palette;
uniform float palette_speed = 0.1;
uniform sampler2D falloff_texture; // Add a 2D sampler for falloff
uniform bool enable_scanlines = true; // Add a toggle for scanlines

void fragment()
{
    // Sample the falloff texture based on UV.x and UV.y
    float falloff = texture(falloff_texture, UV).r;

    // Adjust amplitude based on the falloff value
    float adjusted_amplitude = amplitude * falloff;

    float diff_x = adjusted_amplitude * sin((frequency * UV.y) + (speed * TIME));
    float diff_y = amplitude_vertical * sin((frequency_vertical * UV.y) + (speed_vertical * TIME));
    vec2 scroll = scroll_direction * TIME * scrolling_speed;
    vec4 tex = texture(TEXTURE, vec2(UV.x + diff_x, UV.y + diff_y) + scroll);
    float palette_swap = mod(tex.r - TIME * palette_speed, 1.0);

    if (enable_palette_cycling) {
        COLOR = vec4(texture(palette, vec2(palette_swap, 0)).rgb, tex.a);
    } else {
        COLOR = tex;
		if (COLOR.a > 0.0) {
			COLOR.a = override_alpha;
		}
    }

    if (enable_scanlines) {
        COLOR = mix(vec4(0.0), COLOR, float(int(UV.y * screen_height) % 2));
    }
}
