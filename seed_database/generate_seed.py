import json
import uuid
import random
from datetime import datetime, timedelta

def main():
    # 5 Sample Habits
    habits = [
        {"id": 1, "name": "Morning Run", "description": "Run 5k every morning", "iconCodePoint": 58253, "colorHex": 4283215696, "isLifelong": True, "startDate": "2022-01-01T00:00:00.000Z", "endDate": None},
        {"id": 2, "name": "Read Book", "description": "Read 10 pages", "iconCodePoint": 58280, "colorHex": 4288585374, "isLifelong": True, "startDate": "2022-01-01T00:00:00.000Z", "endDate": None},
        {"id": 3, "name": "Meditate", "description": "10 mins mindfulness", "iconCodePoint": 58313, "colorHex": 4280391411, "isLifelong": True, "startDate": "2022-01-01T00:00:00.000Z", "endDate": None},
        {"id": 4, "name": "Drink Water", "description": "Drink 2L of water", "iconCodePoint": 58354, "colorHex": 4282550004, "isLifelong": True, "startDate": "2022-01-01T00:00:00.000Z", "endDate": None},
        {"id": 5, "name": "Learn Flutter", "description": "Build an app", "iconCodePoint": 58400, "colorHex": 4294198070, "isLifelong": False, "startDate": "2022-01-01T00:00:00.000Z", "endDate": "2026-12-31T00:00:00.000Z"}
    ]

    completions = []
    comp_id = 1
    start_date = datetime(2022, 1, 1)
    end_date = datetime.now()
    delta = end_date - start_date

    # Generate completions over the years with a ~60% completion rate
    for i in range(delta.days + 1):
        current_date = start_date + timedelta(days=i)
        for habit in habits:
            if random.random() > 0.4:
                completions.append({
                    "id": comp_id,
                    "habitId": habit["id"],
                    "completedDate": current_date.isoformat() + "Z"
                })
                comp_id += 1

    # 5 Sample Notes
    notes = [
        {"id": str(uuid.uuid4()), "heading": "Getting Started", "body": "This is the first note in the app. Start exploring features!", "colorHex": 0, "createdAt": "2022-01-01T10:00:00.000Z", "updatedAt": "2022-01-01T10:00:00.000Z"},
        {"id": str(uuid.uuid4()), "heading": "Project Ideas", "body": "- Smart Habit Tracker\n- Personal Portfolio\n- E-commerce App", "colorHex": 1, "createdAt": "2023-05-15T14:30:00.000Z", "updatedAt": "2023-05-15T14:30:00.000Z"},
        {"id": str(uuid.uuid4()), "heading": "Workout Routine", "body": "Monday: Chest & Triceps\nTuesday: Back & Biceps\nWednesday: Legs\nThursday: Shoulders\nFriday: Cardio", "colorHex": 2, "createdAt": "2023-10-10T08:00:00.000Z", "updatedAt": "2023-10-10T08:00:00.000Z"},
        {"id": str(uuid.uuid4()), "heading": "Meeting Notes", "body": "Discussed Q3 goals and new feature rollouts. Need to follow up with the design team.", "colorHex": 3, "createdAt": "2024-02-20T16:45:00.000Z", "updatedAt": "2024-02-20T16:45:00.000Z"},
        {"id": str(uuid.uuid4()), "heading": "Grocery List", "body": "- Milk\n- Eggs\n- Bread\n- Apples\n- Coffee", "colorHex": 4, "createdAt": "2024-05-01T09:15:00.000Z", "updatedAt": "2024-05-01T09:15:00.000Z"}
    ]

    data = {
        "version": 2,
        "habits": habits,
        "completions": completions,
        "notes": notes
    }

    output_file = 'seed_data.json'
    with open(output_file, 'w') as f:
        json.dump(data, f, indent=2)

    print(f"Successfully generated {output_file} with {len(habits)} habits, {len(completions)} completions, and {len(notes)} notes.")

if __name__ == "__main__":
    main()
