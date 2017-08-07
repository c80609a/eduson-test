module UtilsHelper

  # собрать "неправильный" map of ids элементов из +array+
  # +array+ список элементов, у которых есть id (e.id)
  def make_corrupt_ids_map(array)
    raise ArgumentError.new('Массив array должен содержать хотя бы 1 элемент.') if array.size.zero?
    k = array.size / 2 # примерно середина
    array.each_with_index.map { |e,i| i==k ? e.id+100 : e.id }.join(',')
  end

  # от make_corrupt_ids_map отличается только тем,
  # что можно подать имя свойства +pr+, которое
  # содержит строку, и по которому нужно сделать map
  def make_corrupt_map(array, pr)
    raise ArgumentError.new('Массив array должен содержать хотя бы 1 элемент.') if array.size.zero?
    k = array.size / 2 # примерно середина
    array.each_with_index.map { |e,i| i==k ? Faker::Lorem.word : e.send(pr) }.uniq.join(',')
  end

end