shader_type canvas_item;

// This creates a slider in the inspector from 0 to 1
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

// This lets you pick the flash color (default is pure white)
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Get the sprite's current pixel color and transparency
    vec4 color = texture(TEXTURE, UV);

    // Mix the original color with the flash color based on our modifier
    // We only change the RGB, leaving the Alpha (transparency) alone!
    color.rgb = mix(color.rgb, flash_color.rgb, flash_modifier);

    // Output the final color
    COLOR = color;
}