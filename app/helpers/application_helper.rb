module ApplicationHelper
  def authenticated?
    Current.user.present?
  end

  def difficulty_badge(difficulty)
    colors = {
      "easy" => "bg-green-100 text-green-800",
      "medium" => "bg-amber-100 text-amber-800",
      "hard" => "bg-red-100 text-red-800"
    }
    content_tag(:span, difficulty.capitalize, class: "inline-block px-2.5 py-1 text-xs font-semibold rounded-full uppercase #{colors[difficulty]}")
  end

  def score_color(percentage)
    case percentage
    when 80..100 then "text-green-500"
    when 60..79 then "text-amber-500"
    else "text-red-500"
    end
  end

  def score_color_class(percentage)
    case percentage
    when 80..100 then "bg-green-100 text-green-800"
    when 60..79 then "bg-amber-100 text-amber-800"
    else "bg-red-100 text-red-800"
    end
  end

  def pagy_nav(pagy)
    pagy.series_nav
  end
end
