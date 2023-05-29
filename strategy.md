What the app is for
===============================

It was aimed to be a time boxing app.

After creating an account, user is prompted to specify his interests as "Objective <-> Weekly Time To Spend <-> Importance/Priority" combinations.

The user groups are students of secondary and high schools and universities.

The app should help manage the free time, so this time is not spent on something what does not lead to professionals goals.

One of largest desires of the app's author is to support educational processes in his home country which is at the time of this writing one of the poorest countries in Asia.



Let us begin
===============================

- Screen for specifying the goals. Currently, there is no API for roadmaps, which can load the steps to users' goals.
- Another idea is to use Generative AI to show and list the steps for a certain profession.
- The app could consult the user first: suggest some youtube videos or contain general instructions how to choose a dream job


- The next part of development would be specifying the amount of time to be spent on the desired roadmap
- 


First steps
===============================

1. Week plan (working days, weekend: what about shift irregularly scheduled working times?)

Consider scanning and importing PDF/ Excel/ Photos with working times: ML/ Computer Vision

A window with dialog should pop up after first registration. 
"Let us plan your working hours and commute time"

As of now, let's proceed with manual input of working times.

E.g., Mon-Fri: 08:00 - 17:30
Commute +1:30h before and after  

Is it possible to learn during the commute?
If yes, which category do you want to learn, and how much time do you commute without changes?

As of now, do the same schedule for each working day.

2. Model classes

Goal: id, name, deadline, strategy_type, priority, description

Category: id, name, weekly_time, description, total_time_spent: {"Sunday_of_each_week": "time_spent_per_week"}, overall_total_time

ToDo: id, name, time_planned, time_spent, is_done, priority, category_id

ScheduledTask: id, name, start_datetime_planned, end_datetime_planned, start_datetime_as_is, end_datetime_as_is, is_canceled, category_id

