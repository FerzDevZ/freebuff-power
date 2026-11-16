db.orders.aggregate([
  { $match: { status: 'COMPLETED' } },
  { $group: { _id: '$userId', totalSpend: { $sum: '$amount' } } },
  { $sort: { totalSpend: -1 } }
]);
