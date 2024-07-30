/*
Earthbound battle backgrounds shader with scrolling effect and palette cycling like in the original game.
@retr0_dev
Link: https://godotshaders.com/shader/earthbound-like-battle-background-shader-w-scroll-effect-and-palette-cycling/

Apply the shader to a TextureRect or a Sprite. Use a texture with some shapes in a transparent background for best results.
You can then use a ColorRect or another method to paint the background.
You can use the shader on multiple TextureRects and obtain a double-buffer effect tweaking the values for each one, remember to Make Unique the shader material.
*/
shader_type canvas_item;

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
uniform bool enable_hue_shift = false;
uniform float shift_speed = 1.00000; // speed the shift happens
uniform float saturation_aplitude = 1.00000;
uniform float saturation_shift = 0.00000;
uniform float value_aplitude = 1.00000;
uniform float value_shift = 0.00000;

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
    }
    if (enable_hue_shift){
        float time_shift = (TIME * shift_speed);

        vec3 hsv;
    // RGB2HSV:5
        {
            vec3 c = vec3(COLOR.xyz);
            vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
            vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
            float d = q.x - min(q.w, q.y);
            float e = 1.0e-10;
            hsv = vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
        }

    // new HSV:7
        vec3 new_hsv = vec3(time_shift + hsv.r,
                      (hsv.g * saturation_aplitude) + saturation_shift,
                      (hsv.b * value_aplitude) + value_shift);

        vec3 new_rgb;
    // HSV2RGB:8
        {
            vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            vec3 p = abs(fract(new_hsv.xxx + K.xyz) * 6.0 - K.www);
            new_rgb = new_hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), new_hsv.y);
        }

    // Output:0
        COLOR.rgb = new_rgb;
    }

    if (enable_scanlines) {
        COLOR = mix(vec4(0.0), COLOR, float(int(UV.y * screen_height) % 2));
    }
}
