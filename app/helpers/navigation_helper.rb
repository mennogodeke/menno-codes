module NavigationHelper
  NAV_ITEMS = [
    { label: "Home", path: "/" },
    { label: "About", path: "/about" }
  ].freeze

  def nav_items = NAV_ITEMS

  def nav_link(item)
    link_to item[:label], item[:path],
      class: "menu__link",
      aria: (current_page?(item[:path]) ? { current: "page" } : {})
  end
end
