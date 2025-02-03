class CroPhysicianStatuses < EnumerateIt::Base
  associate_values(
    not_found: 0,
    regular: 1
  )
end
