public class Dialogs.Preferences : Gtk.Dialog {
    private Gtk.Stack stack;
    public Preferences () {
        Object (
            transient_for: Application.instance.main_window,
            deletable: true, 
            resizable: true,
            destroy_with_parent: true,
            window_position: Gtk.WindowPosition.CENTER_ON_PARENT,
            modal: true
        );
    }
    
    construct { 
        width_request = 525;
        height_request = 600;

        stack = new Gtk.Stack ();
        stack.expand = true;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        stack.add_named (get_home_widget (), "get_home_widget");
        stack.add_named (get_theme_widget (), "get_theme_widget");

        var stack_scrolled = new Gtk.ScrolledWindow (null, null);
        stack_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        stack_scrolled.width_request = 246;
        stack_scrolled.expand = true;
        stack_scrolled.add (stack);

        get_content_area ().pack_start (stack_scrolled, true, true, 0);

        get_action_area ().visible = false;
        get_action_area ().no_show_all = true;
    }

    private Gtk.Widget get_home_widget () {
        var start_page_item = new PreferenceItem ("go-home", "Start Page", "Inbox");
        var badge_item = new PreferenceItem ("planner-badge-count", "Badge Count", "Today");
        var theme_item = new PreferenceItem ("night-light", "Theme", "Light", true);

        var general_label = new Granite.HeaderLabel (_("General"));
        general_label.margin_start = 6;

        var general_grid = new Gtk.Grid ();
        general_grid.valign = Gtk.Align.START;
        general_grid.get_style_context ().add_class ("view");
        general_grid.orientation = Gtk.Orientation.VERTICAL;
        general_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        general_grid.add (start_page_item);
        general_grid.add (badge_item);
        general_grid.add (theme_item);
        general_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        var main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        main_grid.valign = Gtk.Align.START;
        main_grid.add (general_label);
        main_grid.add (general_grid);

        theme_item.activate_item.connect (() => {
            stack.visible_child_name = "get_theme_widget";
        });

        return main_grid;
    }

    private Gtk.Widget get_theme_widget () {
        var info_box = new PreferenceInfo ("night-light", "Theme", "Aascas ascasc ascasc asc");

        var light_radio = new Gtk.RadioButton.with_label (null, _("Light"));
        light_radio.margin_start = 12;
        light_radio.get_style_context ().add_class ("h3");
        
        var night_radio = new Gtk.RadioButton.with_label_from_widget (light_radio, _("Night"));
        night_radio.margin_start = 12;
        night_radio.get_style_context ().add_class ("h3");

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        main_box.get_style_context ().add_class ("view");
        main_box.expand = true;

        main_box.pack_start (info_box, false, false, 0);
        main_box.pack_start (light_radio, false, false, 0);
        main_box.pack_start (night_radio, false, false, 0);

        if (Application.settings.get_boolean ("prefer-dark-style")) {
            night_radio.active = true;
        }

        info_box.activate_back.connect (() => {
            stack.visible_child_name = "get_home_widget";
        });

        light_radio.toggled.connect (() => {
            Application.settings.set_boolean ("prefer-dark-style", false);
        });

        night_radio.toggled.connect (() => {
            Application.settings.set_boolean ("prefer-dark-style", true);
        });

        return main_box;
    }
}

public class PreferenceItem : Gtk.EventBox {
    private Gtk.Image icon_image;
    private Gtk.Label title_label;
    private Gtk.Label selected_label;

    public string _title;
    public string title {
        get {
            return _title;
        }

        set {
            _title = value;
            title_label.label = _title;
        }
    }

    public string _selected;
    public string selected {
        get {
            return _selected;
        }

        set {
            _selected = value;
            selected_label.label = _selected;
        }
    }

    public string _icon;
    public string icon {
        get {
            return _icon;
        }

        set {
            _icon = value;
            icon_image.gicon = new ThemedIcon (_icon);
        }
    }

    public bool last { get; construct; }

    public signal void activate_item ();

    public PreferenceItem (string icon, string title, string selected, bool last=false) {
        Object (
            icon: icon,
            title: title,
            selected: selected,
            last: last
        );
    }

    construct {
        icon_image = new Gtk.Image ();
        icon_image.pixel_size = 24;

        title_label = new Gtk.Label (null);
        title_label.get_style_context ().add_class ("h3");
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.halign = Gtk.Align.START;
        title_label.valign = Gtk.Align.CENTER;

        selected_label = new Gtk.Label (null);
        selected_label.get_style_context ().add_class ("dim-label");
        selected_label.hexpand = true;
        selected_label.halign = Gtk.Align.END;
        selected_label.valign = Gtk.Align.CENTER;
        selected_label.ellipsize = Pango.EllipsizeMode.END;

        var button_icon = new Gtk.Image ();
        button_icon.gicon = new ThemedIcon ("pan-end-symbolic");
        button_icon.valign = Gtk.Align.CENTER;
        button_icon.pixel_size = 16;

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        box.hexpand = true;
        box.margin = 6;
        box.pack_start (icon_image, false, false, 0);
        box.pack_start (title_label, false, false, 0);
        box.pack_end (button_icon, false, true, 0);
        //box.pack_end (selected_label, false, true, 0);

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_start = 32;

        if (last) {
            separator.visible = false;
            separator.no_show_all = true;
        }

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.add (box);
        main_box.add (separator);

        add (main_box);

        button_press_event.connect ((sender, evt) => {
            if (evt.type == Gdk.EventType.BUTTON_PRESS) {
                activate_item ();

                return true;
            }

            return false;
        });
    }
}

public class PreferenceInfo : Gtk.Box {
    public signal void activate_back ();

    public PreferenceInfo (string icon, string title, string description) {
        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.valign = Gtk.Align.CENTER;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var title_button = new Gtk.Label (title);
        title_button.get_style_context ().add_class ("font-bold");

        var image = new Gtk.Image ();
        image.gicon = new ThemedIcon (icon);
        image.pixel_size = 24;
        
        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.margin = 6;
        header_box.margin_top = 3;
        header_box.margin_bottom = 3;
        header_box.pack_start (back_button, false, false, 0);
        header_box.set_center_widget (title_button);
        header_box.pack_end (image, false, false, 0);

        var description_label = new Gtk.Label (description);
        description_label.margin = 12;
        description_label.margin_bottom = 6;
        description_label.get_style_context ().add_class ("h3");
        description_label.get_style_context ().add_class ("description-label");
        description_label.wrap = true;
        description_label.xalign = 0;

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.hexpand = true;
        main_box.get_style_context ().add_class ("view");
        main_box.valign = Gtk.Align.START;
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        main_box.pack_start (header_box);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        main_box.pack_start (description_label);

        back_button.clicked.connect (() => {
            activate_back ();
        });

        add (main_box);
    }
}