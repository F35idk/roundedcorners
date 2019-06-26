
namespace Gala.Plugins.RoundedCorners
{
    public class Main : Gala.Plugin
    {
        Gala.WindowManager wm;
        
        public override void initialize (Gala.WindowManager wm)
        {
            this.wm = wm;
            var screen = this.wm.get_screen ();
            var display = screen.get_display ();
            display.window_created.connect (this.on_window_creation);
            
            foreach (unowned Meta.WindowActor actor in Meta.Compositor.get_window_actors (screen)) {
                if (actor.is_destroyed ())
                    continue;
                    
                this.on_window_creation (display, actor.get_meta_window ());
            }
        }

        public override void destroy ()
        {
            foreach (unowned Meta.WindowActor actor in Meta.Compositor.get_window_actors (this.wm.get_screen ())) {
                if (actor.is_destroyed ())
                    continue;
                    
                Meta.Window window = actor.get_meta_window ();
                window.position_changed.disconnect (this.on_window_update);
                window.size_changed.disconnect (this.on_window_update);
                
                Clutter.Actor? texture_actor = get_texture_actor (window);
                if (texture_actor != null)
                    texture_actor.remove_effect_by_name ("corner_effect");
            }
        }
        
        void on_window_creation (Meta.Display display, Meta.Window window)
        {
            this.add_effect_to_window (window);
            this.on_window_update (window);
            window.position_changed.connect (this.on_window_update);
            window.size_changed.connect (this.on_window_update);
        }
        
        void on_window_update (Meta.Window window)
        {
            Clutter.Actor? texture_actor = this.get_texture_actor (window);
            if (texture_actor != null) {
                var corner_effect = texture_actor.get_effect ("corner_effect") as CornerEffect;
                if (window.fullscreen || window.maximized_horizontally || window.maximized_vertically)
                    texture_actor.remove_effect_by_name ("corner_effect");
                else
                    this.add_effect_to_window (window);
            }
        }
        
        void add_effect_to_window (Meta.Window window)
        {
            Clutter.Actor? texture_actor = this.get_texture_actor (window);
            var settings = RoundedCornerSettings.get_default ();
            var corner_effect = new CornerEffect (window, settings.corner_radius, 
                                                    settings.corner_offset, settings.smoothing_level);
            texture_actor.add_effect_with_name ("corner_effect", corner_effect);
        }
        
        Clutter.Actor? get_texture_actor (Meta.Window window)
        {
            var window_actor = window.get_compositor_private () as Meta.WindowActor;
            Clutter.Actor? texture_actor = window_actor.get_texture ();
            return texture_actor;
        }
    }
    
    public class CornerEffect : Clutter.ShaderEffect
    {
        float corner_radius;
        float corner_offset;
        float smoothing_level;
        public float left_hor_offset { get; private set; default = 2f; }
        public float top_vert_offset { get; private set; default = 2f; }
        public float total_hor_offset { get; private set; default = 3f; }
        public float total_vert_offset { get; private set; default = 3f; }
        
        public CornerEffect (Meta.Window window, double corner_radius, double corner_offset, double smoothing_level)
        {
            Object (shader_type: Clutter.ShaderType.FRAGMENT_SHADER);
            
            string shader_source;
            FileUtils.get_contents (Config.PKGDATADIR + "/CornerEffect.frag", out shader_source);
            
            this.set_shader_source (shader_source);
            this.corner_radius = (float) corner_radius;
            this.corner_offset = (float) corner_offset;
            this.smoothing_level = (float) smoothing_level;
            // we may be doing more maths than necessary with these offsets
            this.set_frame_to_buffer_offsets (window);
        }
        
        public override void paint_target () 
        {
            float texture_width;
            float texture_height;
            this.get_target_size (out texture_width, out texture_height);
            
            this.set_uniform_value ("width", texture_width);
            this.set_uniform_value ("height", texture_height);
            this.set_uniform_value ("left_hor_offset", this.left_hor_offset - this.corner_offset);
            this.set_uniform_value ("top_vert_offset", this.top_vert_offset - this.corner_offset);
            this.set_uniform_value ("total_hor_offset", this.total_hor_offset - this.corner_offset * 2);
            this.set_uniform_value ("total_vert_offset", this.total_vert_offset - this.corner_offset * 2);
            this.set_uniform_value ("corner_radius", this.corner_radius);
            this.set_uniform_value ("smoothing_level", this.smoothing_level);
            
            base.paint_target ();
        }
        
        // in order to figure out where in the window buffer the corners of the window are, we need 
        // to calculate how offset the window frame is from the window buffer (the window frame never covers
        // the entire window buffer, there is always some extra invisible area around it).
        void set_frame_to_buffer_offsets (Meta.Window window)
        {
            Meta.Rectangle buffer_rect = window.get_buffer_rect ();
            Meta.Rectangle frame_rect = window.get_frame_rect ();
            
            this.left_hor_offset = frame_rect.x - buffer_rect.x + 2f;
            this.top_vert_offset = frame_rect.y - buffer_rect.y + 2f;
            this.total_hor_offset = buffer_rect.width - frame_rect.width + 3f;
            this.total_vert_offset = buffer_rect.height - frame_rect.height + 3f;
        }
    }
}

public Gala.PluginInfo register_plugin ()
{
    return {
        "roundedcorners-plugin",
        "me",
        typeof (Gala.Plugins.RoundedCorners.Main),
        Gala.PluginFunction.ADDITION,
        Gala.LoadPriority.IMMEDIATE
    };
}
