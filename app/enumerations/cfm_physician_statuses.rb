class CfmPhysicianStatuses < EnumerateIt::Base
  associate_values(
    not_found: 0,
    regular: 1,
    permanently_partial_suspended: 2,
    anulled: 3,
    inoperative: 4,
    dead: 5,
    not_regulated_for_region: 6,
    precautionary_interdiction: 7,
    partial_suspended_by_court_order: 8,
    canceled: 9,
    temporary_full_suspended: 10,
    partial_precautionary_interdiction: 11,
    suspended_by_court_order: 12,
    retired: 13,
    temporary_suspended: 14,
    fully_suspended: 15,
    transferred: 16,
    partial_suspended: 17
  )
end
