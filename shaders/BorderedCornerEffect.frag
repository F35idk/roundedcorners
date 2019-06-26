
uniform float width;
uniform float height;
uniform float corner_radius;
uniform float smoothing_level;
uniform float left_hor_offset;
uniform float top_vert_offset;
uniform float total_hor_offset;
uniform float total_vert_offset;
uniform sampler2D tex;

void main ()
{
    vec2 window_dimensions = vec2(width, height);
    vec2 window_coords = cogl_tex_coord_in[0].xy * window_dimensions;
    window_coords = vec2(window_coords.x-left_hor_offset, window_coords.y-top_vert_offset); // 1.5
    window_dimensions = vec2(width-total_hor_offset, height-total_vert_offset); // 3.0
    
    vec2 corner_distance = min(window_coords, window_dimensions - window_coords);
    float corner_alpha = 0.0;
    
    vec4 cogl_tex = texture2D(tex, cogl_tex_coord_in[0].xy);
    cogl_color_out = cogl_tex;
    
    if (max(corner_distance.x, corner_distance.y) <= corner_radius)
        corner_alpha = smoothstep(corner_radius-smoothing_level, corner_radius, distance(corner_distance, vec2(corner_radius, corner_radius)));
    
    cogl_color_out.rgb *= (corner_alpha-1)*-1;
    cogl_color_out *= (corner_alpha-1)*-1;
}
