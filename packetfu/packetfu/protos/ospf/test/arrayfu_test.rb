load "core.rb"

include StructFu

a = ArrayFu.new.read([LSANetRouter.new])
p a.class #=> Array

