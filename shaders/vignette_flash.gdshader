shader_type canvas_item;

// Uniforms allow us to control these values dynamically via code or the Inspector
uniform vec4 flash_color : source_color = vec4(0.5, 0.0, 0.0, 1.0); // Deep red
uniform float multiplier = 1.0;                                    // Overall intensity
uniform float softness = 0.6;                                      // Smoothness of the edge
uniform float radius = 0.2;                                        // How far out from center it starts

void fragment() {
    // 1. Calculate the distance of the current pixel from the center of the screen (0.5, 0.5)
    float dist = distance(UV, vec2(0.5, 0.5));
    
    // 2. Use smoothstep to create a smooth gradient fade toward the corners
    float vignette = smoothstep(radius, radius + softness, dist);
    
    // 3. Apply our intensity multiplier
    vignette = clamp(vignette * multiplier, 0.0, 1.0);
    
    // 4. Mix the screen texture (transparent) with our flash color based on the vignette math
    COLOR = vec4(flash_color.rgb, vignette * flash_color.a);
}