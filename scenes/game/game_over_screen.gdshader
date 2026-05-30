shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise_texture; // Assign a FastNoiseLite texture here in the inspector
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge_color : source_color = vec4(0.8, 0.1, 0.1, 1.0); // Red burn edge

void fragment() {
    vec4 bg_color = texture(screen_texture, SCREEN_UV);
    
    // Read the grayscale value of the noise texture
    float noise_val = texture(noise_texture, UV).r;
    
    if (noise_val < dissolve_amount) {
        // Pixel is fully dissolved, turn it black (or transparent)
        COLOR = vec4(0.0, 0.0, 0.0, 1.0); 
    } else if (noise_val < dissolve_amount + 0.05) {
        // The edge of the dissolve gets a highlight color
        COLOR = edge_color; 
    } else {
        // Show the normal game screen
        COLOR = bg_color; 
    }
}