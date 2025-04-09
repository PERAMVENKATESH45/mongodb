//users
{
  _id: 1,
  name: "venky",
  email: "venky@example.com",
  batch: "B45WD",
  mentor_id: 11
}

//codekata
{
  user_id: 1,
  problems_solved: 120
}

//attendance 
{
  user_id: 2,
  date: ISODate("2020-10-20"),
  present: true
}

//topics
{
  task_name: "JavaScript Task",
  topic_id: 45,
  user_id: 1,
  due_date: ISODate("2020-10-20"),
  submitted: false
}
//company_drives
{
  drive_date: ISODate("2020-10-25"),
  company: "TCS",
  attended_students: [1, 2]
}
//mentors
{
  _id: 11,
  name: "Mentor A",
  mentees: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
}


//1. Find all the topics and tasks which are taught in the month of October
// Topics
db.topics.find({
  date: {
    $gte: ISODate("2020-10-01"),
    $lte: ISODate("2020-10-31")
  }
})


db.tasks.find({
  due_date: {
    $gte: ISODate("2020-10-01"),
    $lte: ISODate("2020-10-31")
  }
})


//2. Find all the company drives which appeared between 15-oct-2020 and 31-oct-2020
db.company_drives.find({
  drive_date: {
    $gte: ISODate("2020-10-15"),
    $lte: ISODate("2020-10-31")
  }
})

//3. Find all the company drives and students who appeared for the placement
db.company_drives.aggregate([
  {
    $project: {
      company: 1,
      drive_date: 1,
      attended_students: 1
    }
  },
  {
    $lookup: {
      from: "users",
      localField: "attended_students",
      foreignField: "_id",
      as: "students_attended"
    }
  }
])

// Find the number of problems solved by the user in codekata
db.codekata.aggregate([
  {
    $lookup: {
      from: "users",
      localField: "user_id",
      foreignField: "_id",
      as: "user_details"
    }
  },
  {
    $project: {
      _id: 0,
      user: { $arrayElemAt: ["$user_details.name", 0] },
      problems_solved: 1
    }
  }
])

// Find all the mentors who have mentees count more than 15
db.mentors.find({
  $expr: { $gt: [{ $size: "$mentees" }, 15] }
})

// Find the number of users who are absent and task is not submitted between 15-oct-2020 and 31-oct-2020
db.attendance.aggregate([
  {
    $match: {
      date: {
        $gte: ISODate("2020-10-15"),
        $lte: ISODate("2020-10-31")
      },
      present: false
    }
  },
  {
    $lookup: {
      from: "tasks",
      let: { userId: "$user_id" },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                { $eq: ["$user_id", "$$userId"] },
                { $eq: ["$submitted", false] },
                { $gte: ["$due_date", ISODate("2020-10-15")] },
                { $lte: ["$due_date", ISODate("2020-10-31")] }
              ]
            }
          }
        }
      ],
      as: "pending_tasks"
    }
  },
  {
    $match: {
      "pending_tasks.0": { $exists: true }
    }
  },
  {
    $count: "users_absent_and_not_submitted"
  }
])



