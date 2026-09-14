module NavigationHelper
  NAV_ITEMS = [
    { key: :home, label_key: "nav.home" },
    { key: :about, label_key: "nav.about" }
  ].freeze

  LOCALES = %i[ en nl de ].freeze

  def nav_items = NAV_ITEMS

  def nav_link(item)
    href = nav_href(item[:key])
    link_to t(item[:label_key]), href,
      class: "menu__link",
      aria: (current_page?(href) ? { current: "page" } : {})
  end

  # Only Home/About are locale-scoped (config/routes.rb) — the switcher only
  # makes sense there, since nothing else has translations to switch between.
  def locale_switcher?
    controller_name == "pages" && action_name.in?(%w[ home about ])
  end

  def locale_switch_link(locale)
    link_to locale.to_s.upcase, locale_switch_path(locale),
      class: class_names("switcher__opt", "is-active": I18n.locale == locale)
  end

  private

  # Only Home/About are locale-scoped (config/routes.rb) — pass the current
  # locale explicitly here rather than via default_url_options, which would
  # leak a stray ?locale= onto every other route (session, /cv, /users).
  def nav_href(key)
    locale_path(key, I18n.locale == I18n.default_locale ? nil : I18n.locale)
  end

  def locale_switch_path(locale)
    locale_path(action_name.to_sym, locale == I18n.default_locale ? nil : locale)
  end

  def locale_path(key, locale)
    case key
    when :home then root_path(locale:)
    when :about then about_path(locale:)
    end
  end
end
