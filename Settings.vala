
namespace Gala.Plugins.RoundedCorners 
{
    public class RoundedCornerSettings : Granite.Services.Settings
    {
        static RoundedCornerSettings? settings_instance = null;
        
        public static unowned RoundedCornerSettings get_default ()
        {
            if (settings_instance == null)
                settings_instance = new RoundedCornerSettings ();
            
            return settings_instance;
        }
        
        public double corner_radius { get; set; default = 6.5; }
        public double corner_offset { get; set; default = 1.0; }
        public double smoothing_level {get; set; default = 2.0; }
        
        RoundedCornerSettings ()
        {
            base (Config.SCHEMA + ".rounded-corners");
        }
    }
}
