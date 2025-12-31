module ApplicationHelper
  def authenticated?
    Current.user.present?
  end

  def difficulty_badge(difficulty)
    colors = {
      "easy" => "badge-success",
      "medium" => "badge-warning",
      "hard" => "badge-error"
    }
    content_tag(:span, difficulty.capitalize, class: "badge #{colors[difficulty]}")
  end

  def score_color(percentage)
    case percentage
    when 80..100 then "text-success"
    when 60..79 then "text-warning"
    else "text-error"
    end
  end
end
