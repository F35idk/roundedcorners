
uniform float width;
uniform float height;
uniform float corner_radius;
uniform float smoothing_level;
uniform sampler2D tex;
uniform float left_hor_offset;
uniform float top_vert_offset;
uniform float total_hor_offset;
uniform float total_vert_offset;

void main ()
{
    float corner_radius = corner_radius + 1.0;
    float smoothing_level = smoothing_level + 0.5;
    
    vec2 window_dimensions = vec2(width, height);
    vec2 window_coords = cogl_tex_coord_in[0].xy * window_dimensions;
    window_coords = vec2(window_coords.x-left_hor_offset+0.5, window_coords.y-top_vert_offset+0.5); // 1.5
    window_dimensions = vec2(width-total_hor_offset+1.0, height-total_vert_offset+1.0); // 3.0
    
    vec2 corner_distance = min(window_coords, window_dimensions - window_coords);
    float corner_alpha = 0.0;
    float border_color = 0.0;
    
    vec4 cogl_tex = texture2D(tex, cogl_tex_coord_in[0].xy);
    cogl_color_out = cogl_tex;
    
    if (max(corner_distance.x+0.5, corner_distance.y+0.5) <= corner_radius) { // + 0.5 each dist
        corner_alpha = smoothstep(corner_radius-smoothing_level, corner_radius, distance(corner_distance, vec2(corner_radius, corner_radius)));
        border_color = smoothstep(corner_radius-2.4, corner_radius, distance(corner_distance+0.1, vec2(corner_radius, corner_radius)));
    }
    
    cogl_color_out.rgb *= (border_color-1)*-1;
    cogl_color_out *= (corner_alpha-1)*-1;
}
