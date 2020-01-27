# frozen_string_literal: true

class ConvoyOrder < Order
  def convoy?
    true
  end

  def to_s
    # 輸送命令では海岸表記が絡んでくることはないが一応支援命令に合わせる
    format(
      '%<kind>s %<prov>s C %<target>s',
      kind: unit_kind,
      prov: unit.province,
      target: formated_target
    ).gsub(/_(..)/, '(\1)')
  end
end
