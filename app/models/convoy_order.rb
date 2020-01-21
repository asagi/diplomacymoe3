# frozen_string_literal: true

class ConvoyOrder < Order
  def convoy?
    true
  end

  def to_s
    # 輸送命令では海岸表記が絡んでくることはないが一応支援命令に合わせる
    format(
      '%s %s C %s',
      unit_kind,
      unit.province,
      formated_target
    ).gsub(/_(..)/, '(\1)')
  end
end
