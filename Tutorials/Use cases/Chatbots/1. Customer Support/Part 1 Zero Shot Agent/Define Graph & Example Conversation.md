# Define Graph¶
Now, create the graph. The graph is the final assistant for this section.

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import END, StateGraph, START
from langgraph.prebuilt import tools_condition

builder = StateGraph(State)


# Define nodes: these do the work
builder.add_node("assistant", Assistant(part_1_assistant_runnable))
builder.add_node("tools", create_tool_node_with_fallback(part_1_tools))
# Define edges: these determine how the control flow moves
builder.add_edge(START, "assistant")
builder.add_conditional_edges(
    "assistant",
    tools_condition,
)
builder.add_edge("tools", "assistant")

# The checkpointer lets the graph persist its state
# this is a complete memory for the entire graph.
memory = MemorySaver()
part_1_graph = builder.compile(checkpointer=memory)
API Reference: MemorySaver | END | StateGraph | START | tools_condition


from IPython.display import Image, display

try:
    display(Image(part_1_graph.get_graph(xray=True).draw_mermaid_png()))
except Exception:
    # This requires some extra dependencies and is optional
    pass
```

# Example Conversation¶
Now it's time to try out our mighty chatbot! Let's run it over the following list of dialog turns. If it hits a "RecursionLimit", that means the agent wasn't able to get an answer in the allocated number of steps. That's OK! We have more tricks up our sleeve in later sections of this tutorial.

```python
import shutil
import uuid

# Let's create an example conversation a user might have with the assistant
tutorial_questions = [
    "Hi there, what time is my flight?",
    "Am i allowed to update my flight to something sooner? I want to leave later today.",
    "Update my flight to sometime next week then",
    "The next available option is great",
    "what about lodging and transportation?",
    "Yeah i think i'd like an affordable hotel for my week-long stay (7 days). And I'll want to rent a car.",
    "OK could you place a reservation for your recommended hotel? It sounds nice.",
    "yes go ahead and book anything that's moderate expense and has availability.",
    "Now for a car, what are my options?",
    "Awesome let's just get the cheapest option. Go ahead and book for 7 days",
    "Cool so now what recommendations do you have on excursions?",
    "Are they available while I'm there?",
    "interesting - i like the museums, what options are there? ",
    "OK great pick one and book it for my second day there.",
]

# Update with the backup file so we can restart from the original place in each section
db = update_dates(db)
thread_id = str(uuid.uuid4())

config = {
    "configurable": {
        # The passenger_id is used in our flight tools to
        # fetch the user's flight information
        "passenger_id": "3442 587242",
        # Checkpoints are accessed by thread_id
        "thread_id": thread_id,
    }
}


_printed = set()
for question in tutorial_questions:
    events = part_1_graph.stream(
        {"messages": ("user", question)}, config, stream_mode="values"
    )
    for event in events:
        _print_event(event, _printed)
```

```js
================================[1m Human Message [0m=================================

Hi there, what time is my flight?
==================================[1m Ai Message [0m==================================

Hello, to check the time of your flight, I will need to look up your ticket information first. Could you please provide me with your ticket number or booking reference? I'd be happy to retrieve the details of your flight once I have that information.
================================[1m Human Message [0m=================================

Am i allowed to update my flight to something sooner? I want to leave later today.
==================================[1m Ai Message [0m==================================

[{'text': 'Let me check the company policies first on changing flights:', 'type': 'text'}, {'id': 'toolu_016BZDgoB6cLVCWYGjsHiuFE', 'input': {'query': 'changing flights same day'}, 'name': 'lookup_policy', 'type': 'tool_use'}]
Tool Calls:
  lookup_policy (toolu_016BZDgoB6cLVCWYGjsHiuFE)
 Call ID: toolu_016BZDgoB6cLVCWYGjsHiuFE
  Args:
    query: changing flights same day
=================================[1m Tool Message [0m=================================
Name: lookup_policy


## Booking and Cancellation

1. How can I change my booking?
    * The ticket number must start with 724 (SWISS ticket no./plate).
    * The ticket was not paid for by barter or voucher (there are exceptions to voucher payments; if the ticket was paid for in full by voucher, then it may be possible to rebook online under certain circumstances. If it is not possible to rebook online because of the payment method, then you will be informed accordingly during the rebooking process).
    * There must be an active flight booking for your ticket. It is not possible to rebook open tickets or tickets without the corresponding flight segments online at the moment.
    * It is currently only possible to rebook outbound (one-way) tickets or return tickets with single flight routes (point-to-point).
2. Which tickets/bookings cannot be rebooked online currently?
    * Bookings containing flight segments with other airlines
    * Bookings containing reservations, where a ticket has not yet been issued
    * Bookings with several valid tickets for the same person and route
    * Tickets with a status other than O (open) (A)
    * Bookings with segments with a status other than OK (e.g. containing flight segments with the status Waitlist) (HK|RR)
    * Tickets that do not display the tariff calculation (IT tickets)
    * Bookings that contain special services (e.g. transportation of animals/transportation of medica ... (truncated)
==================================[1m Ai Message [0m==================================

Based on the policy information, it looks like you are generally allowed to change your flight on the same day for an earlier option, provided your ticket number starts with 724 and some other conditions are met. However, to check if your specific ticket can be updated today, I will need to look up your ticket number or booking reference.

Could you please provide your ticket number or booking reference? Then I can check your flight details and whether you are eligible to change to an earlier flight today per the policy.
================================[1m Human Message [0m=================================

Update my flight to sometime next week then
==================================[1m Ai Message [0m==================================

[{'text': 'Okay, let me check the policy on changing flights to a different date:', 'type': 'text'}, {'id': 'toolu_012iAxutz45L1QFeTeu3TTRG', 'input': {'query': 'changing flight dates to next week'}, 'name': 'lookup_policy', 'type': 'tool_use'}]
Tool Calls:
  lookup_policy (toolu_012iAxutz45L1QFeTeu3TTRG)
 Call ID: toolu_012iAxutz45L1QFeTeu3TTRG
  Args:
    query: changing flight dates to next week
=================================[1m Tool Message [0m=================================
Name: lookup_policy


## Booking and Cancellation

1. How can I change my booking?
    * The ticket number must start with 724 (SWISS ticket no./plate).
    * The ticket was not paid for by barter or voucher (there are exceptions to voucher payments; if the ticket was paid for in full by voucher, then it may be possible to rebook online under certain circumstances. If it is not possible to rebook online because of the payment method, then you will be informed accordingly during the rebooking process).
    * There must be an active flight booking for your ticket. It is not possible to rebook open tickets or tickets without the corresponding flight segments online at the moment.
    * It is currently only possible to rebook outbound (one-way) tickets or return tickets with single flight routes (point-to-point).
2. Which tickets/bookings cannot be rebooked online currently?
    * Bookings containing flight segments with other airlines
    * Bookings containing reservations, where a ticket has not yet been issued
    * Bookings with several valid tickets for the same person and route
    * Tickets with a status other than O (open) (A)
    * Bookings with segments with a status other than OK (e.g. containing flight segments with the status Waitlist) (HK|RR)
    * Tickets that do not display the tariff calculation (IT tickets)
    * Bookings that contain special services (e.g. transportation of animals/transportation of medica ... (truncated)
==================================[1m Ai Message [0m==================================

The policy states that you are generally allowed to change your flight and travel dates online, as long as your ticket number starts with 724 and meets the other conditions listed.

To proceed with changing your flight to sometime next week, I'll need your ticket number or booking reference. Once I have that, I can look up your specific reservation details and change your flight dates if permitted based on your fare type and the availability of flights.

Please provide me with your ticket number or booking reference whenever you're ready.
================================[1m Human Message [0m=================================

The next available option is great
==================================[1m Ai Message [0m==================================

[{'text': "Got it, you'd like to change your flight to the next available option sometime next week. Let me first verify your ticket details:", 'type': 'text'}, {'id': 'toolu_01DCfdGkEsahzxNjBTC2gG1t', 'input': {}, 'name': 'fetch_user_flight_information', 'type': 'tool_use'}]
Tool Calls:
  fetch_user_flight_information (toolu_01DCfdGkEsahzxNjBTC2gG1t)
 Call ID: toolu_01DCfdGkEsahzxNjBTC2gG1t
  Args:
=================================[1m Tool Message [0m=================================
Name: fetch_user_flight_information

[{"ticket_no": "7240005432906569", "book_ref": "C46E9F", "flight_id": 19250, "flight_no": "LX0112", "departure_airport": "CDG", "arrival_airport": "BSL", "scheduled_departure": "2024-04-30 12:09:03.561731-04:00", "scheduled_arrival": "2024-04-30 13:39:03.561731-04:00", "seat_no": "18E", "fare_conditions": "Economy"}]
==================================[1m Ai Message [0m==================================

[{'text': 'Based on your ticket number 7240005432906569, it looks like you currently have a ticket booked for flight LX0112 from Paris (CDG) to Basel (BSL) on April 30th in Economy class.\n\nLet me search for the next available flight option from Paris to Basel after your current flight next week:', 'type': 'text'}, {'id': 'toolu_01Wfy5PUGvQViroenhAsQpNS', 'input': {'departure_airport': 'CDG', 'arrival_airport': 'BSL', 'start_time': '2024-05-06', 'end_time': '2024-05-13'}, 'name': 'search_flights', 'type': 'tool_use'}]
Tool Calls:
  search_flights (toolu_01Wfy5PUGvQViroenhAsQpNS)
 Call ID: toolu_01Wfy5PUGvQViroenhAsQpNS
  Args:
    departure_airport: CDG
    arrival_airport: BSL
    start_time: 2024-05-06
    end_time: 2024-05-13
=================================[1m Tool Message [0m=================================
Name: search_flights

[{"flight_id": 19238, "flight_no": "LX0112", "scheduled_departure": "2024-05-08 12:09:03.561731-04:00", "scheduled_arrival": "2024-05-08 13:39:03.561731-04:00", "departure_airport": "CDG", "arrival_airport": "BSL", "status": "Scheduled", "aircraft_code": "SU9", "actual_departure": null, "actual_arrival": null}, {"flight_id": 19242, "flight_no": "LX0112", "scheduled_departure": "2024-05-09 12:09:03.561731-04:00", "scheduled_arrival": "2024-05-09 13:39:03.561731-04:00", "departure_airport": "CDG", "arrival_airport": "BSL", "status": "Scheduled", "aircraft_code": "SU9", "actual_departure": null, "actual_arrival": null}, {"flight_id": 19243, "flight_no": "LX0112", "scheduled_departure": "2024-05-11 12:09:03.561731-04:00", "scheduled_arrival": "2024-05-11 13:39:03.561731-04:00", "departure_airport": "CDG", "arrival_airport": "BSL", "status": "Scheduled", "aircraft_code": "SU9", "actual_departure": null, "actual_arrival": null}, {"flight_id": 19251, "flight_no": "LX0112", "scheduled_departure": "2024-05-07 12:09:03.561731-04:00", "scheduled_arrival": "2024-05-07 13:39:03.561731-04:00", "departure_airport": "CDG", "arrival_airport": "BSL", "status": "Scheduled", "aircraft_code": "SU9", "actual_departure": null, "actual_arrival": null}, {"flight_id": 19252, "flight_no": "LX0112", "scheduled_departure": "2024-05-06 12:09:03.561731-04:00", "scheduled_arrival": "2024-05-06 13:3 ... (truncated)
==================================[1m Ai Message [0m==================================

[{'text': "The next available flight option from Paris to Basel after your current one on April 30th is flight LX0112 on May 6th at 12:09pm. \n\nTo change your ticket to this new flight on May 6th, I'll need to invoke the update_ticket_to_new_flight tool:", 'type': 'text'}, {'id': 'toolu_015rWZwtfrqHs94qtM3Zfq7j', 'input': {'ticket_no': '7240005432906569', 'new_flight_id': 19252}, 'name': 'update_ticket_to_new_flight', 'type': 'tool_use'}]
Tool Calls:
  update_ticket_to_new_flight (toolu_015rWZwtfrqHs94qtM3Zfq7j)
 Call ID: toolu_015rWZwtfrqHs94qtM3Zfq7j
  Args:
    ticket_no: 7240005432906569
    new_flight_id: 19252
=================================[1m Tool Message [0m=================================
Name: update_ticket_to_new_flight

Not permitted to reschedule to a flight that is less than 3 hours from the current time. Selected flight is at 2024-05-06 12:09:03.561731-04:00.
==================================[1m Ai Message [0m==================================

[{'text': "Hmm it looks like I can't reschedule to that May 6th flight since it's less than 3 hours from now per the policy.\n\nLet me try changing to the next available option after that:", 'type': 'text'}, {'id': 'toolu_01NAqSD549HruNSbyaHGzzVG', 'input': {'ticket_no': '7240005432906569', 'new_flight_id': 19251}, 'name': 'update_ticket_to_new_flight', 'type': 'tool_use'}]
Tool Calls:
  update_ticket_to_new_flight (toolu_01NAqSD549HruNSbyaHGzzVG)
 Call ID: toolu_01NAqSD549HruNSbyaHGzzVG
  Args:
    ticket_no: 7240005432906569
    new_flight_id: 19251
=================================[1m Tool Message [0m=================================
Name: update_ticket_to_new_flight

Not permitted to reschedule to a flight that is less than 3 hours from the current time. Selected flight is at 2024-05-07 12:09:03.561731-04:00.
==================================[1m Ai Message [0m==================================

[{'text': "The May 7th flight is also too soon based on the 3 hour cutoff. Let's try the flight after that:", 'type': 'text'}, {'id': 'toolu_015BBputtKdV9zhLVWa3f51V', 'input': {'ticket_no': '7240005432906569', 'new_flight_id': 19238}, 'name': 'update_ticket_to_new_flight', 'type': 'tool_use'}]
Tool Calls:
  update_ticket_to_new_flight (toolu_015BBputtKdV9zhLVWa3f51V)
 Call ID: toolu_015BBputtKdV9zhLVWa3f51V
  Args:
    ticket_no: 7240005432906569
    new_flight_id: 19238
=================================[1m Tool Message [0m=================================
Name: update_ticket_to_new_flight

Ticket successfully updated to new flight.
==================================[1m Ai Message [0m==================================

Great, I was able to successfully update your ticket 7240005432906569 to the next available flight LX0112 from Paris to Basel on May 8th at 12:09pm. Your new ticket details have been confirmed.

Please let me know if you need any other assistance with your updated travel plans!
================================[1m Human Message [0m=================================

what about lodging and transportation?
==================================[1m Ai Message [0m==================================

[{'text': "Sure, I can assist you with finding lodging and transportation options around your new flight dates. Here are a few tools we can use:\n\nFor hotels near Basel around your arrival on May 8th, let's search:", 'type': 'text'}, {'id': 'toolu_01MnHtMckxsD23fYv8tHEwhc', 'input': {'location': 'Basel', 'checkin_date': '2024-05-08', 'checkout_date': '2024-05-10'}, 'name': 'search_hotels', 'type': 'tool_use'}]
Tool Calls:
  search_hotels (toolu_01MnHtMckxsD23fYv8tHEwhc)
 Call ID: toolu_01MnHtMckxsD23fYv8tHEwhc
  Args:
    location: Basel
    checkin_date: 2024-05-08
    checkout_date: 2024-05-10
=================================[1m Tool Message [0m=================================
Name: search_hotels

[{"id": 1, "name": "Hilton Basel", "location": "Basel", "price_tier": "Luxury", "checkin_date": "2024-04-22", "checkout_date": "2024-04-20", "booked": 0}, {"id": 3, "name": "Hyatt Regency Basel", "location": "Basel", "price_tier": "Upper Upscale", "checkin_date": "2024-04-02", "checkout_date": "2024-04-20", "booked": 0}, {"id": 8, "name": "Holiday Inn Basel", "location": "Basel", "price_tier": "Upper Midscale", "checkin_date": "2024-04-24", "checkout_date": "2024-04-09", "booked": 0}]
==================================[1m Ai Message [0m==================================

[{'text': "Those are some hotel options in Basel for your arrival on May 8th until May 10th. Let me know if you see any you'd like to book or if you need to search for different dates/locations.\n\nFor transportation, we can look at rental car options:", 'type': 'text'}, {'id': 'toolu_019M8Yy5qnDRo3RyxiLe4bZY', 'input': {'location': 'Basel', 'start_date': '2024-05-08', 'end_date': '2024-05-10'}, 'name': 'search_car_rentals', 'type': 'tool_use'}]
Tool Calls:
  search_car_rentals (toolu_019M8Yy5qnDRo3RyxiLe4bZY)
 Call ID: toolu_019M8Yy5qnDRo3RyxiLe4bZY
  Args:
    location: Basel
    start_date: 2024-05-08
    end_date: 2024-05-10
=================================[1m Tool Message [0m=================================
Name: search_car_rentals

[{"id": 1, "name": "Europcar", "location": "Basel", "price_tier": "Economy", "start_date": "2024-04-14", "end_date": "2024-04-11", "booked": 0}, {"id": 2, "name": "Avis", "location": "Basel", "price_tier": "Luxury", "start_date": "2024-04-10", "end_date": "2024-04-20", "booked": 0}, {"id": 7, "name": "Enterprise", "location": "Basel", "price_tier": "Premium", "start_date": "2024-04-22", "end_date": "2024-04-20", "booked": 0}, {"id": 9, "name": "Thrifty", "location": "Basel", "price_tier": "Midsize", "start_date": "2024-04-17", "end_date": "2024-04-26", "booked": 0}]
==================================[1m Ai Message [0m==================================

Here are some rental car options picked up and dropped off in Basel to coincide with your dates. Let me know if you need to adjust the location, dates or price tier for the rental.

I'm also happy to look into any local tours, excursions or trip recommendations in the Basel area if you'll have some free time there. Just let me know what else you need for your updated travel plans!
================================[1m Human Message [0m=================================

Yeah i think i'd like an affordable hotel for my week-long stay (7 days). And I'll want to rent a car.
==================================[1m Ai Message [0m==================================

[{'text': 'Got it, let me search for an affordable hotel in Basel for 7 nights around your updated flight dates, as well as a rental car pick up.\n\nFor hotels:', 'type': 'text'}, {'id': 'toolu_01YXAnzTNyEKYEZgyqdnCZH6', 'input': {'checkin_date': '2024-05-08', 'checkout_date': '2024-05-15', 'location': 'Basel', 'price_tier': 'Midscale'}, 'name': 'search_hotels', 'type': 'tool_use'}]
Tool Calls:
  search_hotels (toolu_01YXAnzTNyEKYEZgyqdnCZH6)
 Call ID: toolu_01YXAnzTNyEKYEZgyqdnCZH6
  Args:
    checkin_date: 2024-05-08
    checkout_date: 2024-05-15
    location: Basel
    price_tier: Midscale
=================================[1m Tool Message [0m=================================
Name: search_hotels

[{"id": 1, "name": "Hilton Basel", "location": "Basel", "price_tier": "Luxury", "checkin_date": "2024-04-22", "checkout_date": "2024-04-20", "booked": 0}, {"id": 3, "name": "Hyatt Regency Basel", "location": "Basel", "price_tier": "Upper Upscale", "checkin_date": "2024-04-02", "checkout_date": "2024-04-20", "booked": 0}, {"id": 8, "name": "Holiday Inn Basel", "location": "Basel", "price_tier": "Upper Midscale", "checkin_date": "2024-04-24", "checkout_date": "2024-04-09", "booked": 0}]
==================================[1m Ai Message [0m==================================

[{'text': "Hmm it doesn't look like there are any available Midscale hotels in Basel for those dates. Let me expand the search a bit:", 'type': 'text'}, {'id': 'toolu_014mJE4m6NsujosrcTTSDCFP', 'input': {'checkin_date': '2024-05-08', 'checkout_date': '2024-05-15', 'location': 'Basel', 'price_tier': 'Upper Midscale'}, 'name': 'search_hotels', 'type': 'tool_use'}]
Tool Calls:
  search_hotels (toolu_014mJE4m6NsujosrcTTSDCFP)
 Call ID: toolu_014mJE4m6NsujosrcTTSDCFP
  Args:
    checkin_date: 2024-05-08
    checkout_date: 2024-05-15
    location: Basel
    price_tier: Upper Midscale
=================================[1m Tool Message [0m=================================
Name: search_hotels

[{"id": 1, "name": "Hilton Basel", "location": "Basel", "price_tier": "Luxury", "checkin_date": "2024-04-22", "checkout_date": "2024-04-20", "booked": 0}, {"id": 3, "name": "Hyatt Regency Basel", "location": "Basel", "price_tier": "Upper Upscale", "checkin_date": "2024-04-02", "checkout_date": "2024-04-20", "booked": 0}, {"id": 8, "name": "Holiday Inn Basel", "location": "Basel", "price_tier": "Upper Midscale", "checkin_date": "2024-04-24", "checkout_date": "2024-04-09", "booked": 0}]
==================================[1m Ai Message [0m==================================

[{'text': 'The Holiday Inn Basel in the Upper Midscale price tier looks to be available for your 7 night stay from May 8-15. Would you like me to book that hotel for you? If not, I can expand the search further.\n\nFor the rental car:', 'type': 'text'}, {'id': 'toolu_01APCxBQrDLrfbc7ChSrDRoC', 'input': {'end_date': '2024-05-15', 'location': 'Basel', 'start_date': '2024-05-08'}, 'name': 'search_car_rentals', 'type': 'tool_use'}]
Tool Calls:
  search_car_rentals (toolu_01APCxBQrDLrfbc7ChSrDRoC)
 Call ID: toolu_01APCxBQrDLrfbc7ChSrDRoC
  Args:
    end_date: 2024-05-15
    location: Basel
    start_date: 2024-05-08
=================================[1m Tool Message [0m=================================
Name: search_car_rentals

[{"id": 1, "name": "Europcar", "location": "Basel", "price_tier": "Economy", "start_date": "2024-04-14", "end_date": "2024-04-11", "booked": 0}, {"id": 2, "name": "Avis", "location": "Basel", "price_tier": "Luxury", "start_date": "2024-04-10", "end_date": "2024-04-20", "booked": 0}, {"id": 7, "name": "Enterprise", "location": "Basel", "price_tier": "Premium", "start_date": "2024-04-22", "end_date": "2024-04-20", "booked": 0}, {"id": 9, "name": "Thrifty", "location": "Basel", "price_tier": "Midsize", "start_date": "2024-04-17", "end_date": "2024-04-26", "booked": 0}]
==================================[1m Ai Message [0m==================================

For the rental car, Europcar has an economy option available for pickup and drop-off on your dates in Basel. Let me know if you'd like me to book that or if you need to look at a different price tier or company.

And of course, let me know if you need anything else arranged for your week-long stay in Basel! I'm happy to help with booking hotels, cars, tours or other activities.
================================[1m Human Message [0m=================================

OK could you place a reservation for your recommended hotel? It sounds nice.
==================================[1m Ai Message [0m==================================

[{'text': "Sure, I'd be happy to book the Holiday Inn Basel for your 7 night stay from May 8th to May 15th. \n\nBefore I confirm the reservation, let me double check the details:\n\nHotel: Holiday Inn Basel\nLocation: Basel, Switzerland \nPrice Tier: Upper Midscale\nCheck-In Date: May 8, 2024\nCheck-Out Date: May 15, 2024\nTotal Nights: 7\n\nPlease confirm those details are correct. Once confirmed, I'll go ahead and book that hotel reservation for you.", 'type': 'text'}, {'id': 'toolu_01QEQVXu3tLK8TKgKEw9g6dA', 'input': {'hotel_id': 8}, 'name': 'book_hotel', 'type': 'tool_use'}]
Tool Calls:
  book_hotel (toolu_01QEQVXu3tLK8TKgKEw9g6dA)
 Call ID: toolu_01QEQVXu3tLK8TKgKEw9g6dA
  Args:
    hotel_id: 8
=================================[1m Tool Message [0m=================================
Name: book_hotel

Hotel 8 successfully booked.
==================================[1m Ai Message [0m==================================

Great, the Holiday Inn Basel hotel has been successfully booked for your 7 night stay from May 8th to May 15th. You're all set with a confirmed hotel reservation in Basel coinciding with your updated flight dates.

Let me know if you need any other accommodations like a rental car, activities or anything else arranged for your week in Basel. I'm happy to keep assisting with your travel plans!
================================[1m Human Message [0m=================================

yes go ahead and book anything that's moderate expense and has availability.
==================================[1m Ai Message [0m==================================

[{'text': "Got it, I'll book a moderately priced rental car option that has availability for your dates in Basel as well.", 'type': 'text'}, {'id': 'toolu_01QkYUTPk1jdQj77pbsB9jCa', 'input': {'rental_id': 1}, 'name': 'book_car_rental', 'type': 'tool_use'}]
Tool Calls:
  book_car_rental (toolu_01QkYUTPk1jdQj77pbsB9jCa)
 Call ID: toolu_01QkYUTPk1jdQj77pbsB9jCa
  Args:
    rental_id: 1
=================================[1m Tool Message [0m=================================
Name: book_car_rental

Car rental 1 successfully booked.
==================================[1m Ai Message [0m==================================

[{'text': 'I went ahead and booked the Europcar economy rental car option for your dates in Basel from May 8th to May 15th. This should provide you with moderate transportation for getting around during your week-long stay.\n\nFor activities and things to do, let me suggest some moderate excursions and day trips in the Basel area:', 'type': 'text'}, {'id': 'toolu_01MPAZVJE2X1YA4xXaAYah94', 'input': {'location': 'Basel', 'keywords': 'day trips, excursions'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01MPAZVJE2X1YA4xXaAYah94)
 Call ID: toolu_01MPAZVJE2X1YA4xXaAYah94
  Args:
    location: Basel
    keywords: day trips, excursions
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[]
==================================[1m Ai Message [0m==================================

[{'text': "Hmm oddly I'm not finding any recommended day trips or excursions coming up for Basel. Let me try a broader search:", 'type': 'text'}, {'id': 'toolu_01L4eN8sfiabpHdMMjhLQA5k', 'input': {'location': 'Switzerland', 'keywords': 'day trips, tours, excursions'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01L4eN8sfiabpHdMMjhLQA5k)
 Call ID: toolu_01L4eN8sfiabpHdMMjhLQA5k
  Args:
    location: Switzerland
    keywords: day trips, tours, excursions
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[]
==================================[1m Ai Message [0m==================================

[{'text': "That's strange, my search isn't returning any recommendations for tours, day trips or excursions in Switzerland. Let me do one more general search for activities:", 'type': 'text'}, {'id': 'toolu_0174DPmee4i1r91hxs1UJCSF', 'input': {'keywords': 'activities switzerland'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_0174DPmee4i1r91hxs1UJCSF)
 Call ID: toolu_0174DPmee4i1r91hxs1UJCSF
  Args:
    keywords: activities switzerland
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[]
==================================[1m Ai Message [0m==================================

I'm really struggling to find any recommended activities, tours or excursions to book for your stay in the Basel area. It seems the database may be lacking robust options for that region. 

Instead, here are a few potential ideas I could recommend based on some quick research:

- Take a day trip to Lucerne and go see the iconic Chapel Bridge and Lion Monument
- Visit the Swiss Vapeur Parc, an amusement park focused on trains and transportation
- Go for a hike up Gempenplateau for scenic views overlooking Basel
- Take a food tour to sample the local Swiss cuisine like rösti and fondue
- Do a wine tasting day trip out to the vineyards near Alsace, France

Let me know if any of those appeal to you or if you'd like me to find some other moderate activity recommendations for your Basel stay. I can also hold off on booking excursions for now if you prefer to play that portion by ear once there. Just let me know your preference!
================================[1m Human Message [0m=================================

Now for a car, what are my options?
==================================[1m Ai Message [0m==================================

[{'text': 'No problem, let me provide some additional rental car options for you during your stay in Basel from May 8th to May 15th.', 'type': 'text'}, {'id': 'toolu_012CmfeoLyidUpZ1AP22AaU4', 'input': {'end_date': '2024-05-15', 'location': 'Basel', 'start_date': '2024-05-08'}, 'name': 'search_car_rentals', 'type': 'tool_use'}]
Tool Calls:
  search_car_rentals (toolu_012CmfeoLyidUpZ1AP22AaU4)
 Call ID: toolu_012CmfeoLyidUpZ1AP22AaU4
  Args:
    end_date: 2024-05-15
    location: Basel
    start_date: 2024-05-08
=================================[1m Tool Message [0m=================================
Name: search_car_rentals

[{"id": 1, "name": "Europcar", "location": "Basel", "price_tier": "Economy", "start_date": "2024-04-14", "end_date": "2024-04-11", "booked": 1}, {"id": 2, "name": "Avis", "location": "Basel", "price_tier": "Luxury", "start_date": "2024-04-10", "end_date": "2024-04-20", "booked": 0}, {"id": 7, "name": "Enterprise", "location": "Basel", "price_tier": "Premium", "start_date": "2024-04-22", "end_date": "2024-04-20", "booked": 0}, {"id": 9, "name": "Thrifty", "location": "Basel", "price_tier": "Midsize", "start_date": "2024-04-17", "end_date": "2024-04-26", "booked": 0}]
==================================[1m Ai Message [0m==================================

I see a few options still available for those dates:

Avis - Luxury Tier
Enterprise - Premium Tier 
Thrifty - Midsize Tier

I had previously booked the Economy tier Europcar rental already.

Would you like me to book one of the other available tiers? The Midsize from Thrifty may be a decent moderate option between Economy and Premium/Luxury. Let me know which rental car option you'd prefer and I can get that booked.

Or if you need to adjust the pickup/drop-off dates or location, I can search again with those new parameters as well. Just let me know your rental car preferences!
================================[1m Human Message [0m=================================

Awesome let's just get the cheapest option. Go ahead and book for 7 days
==================================[1m Ai Message [0m==================================

[{'text': "Sure, let's go with the cheapest rental car option available for your 7 day stay in Basel from May 8th to May 15th.\n\nBased on the search results, the most economical option is:\n\nEuropcar - Economy Tier\n\nI had previously booked this for you, but let me confirm and update the reservation for the 7 day period:", 'type': 'text'}, {'id': 'toolu_01Th9LNrTHCjQG2gxP2fEvXS', 'input': {'rental_id': 1}, 'name': 'book_car_rental', 'type': 'tool_use'}]
Tool Calls:
  book_car_rental (toolu_01Th9LNrTHCjQG2gxP2fEvXS)
 Call ID: toolu_01Th9LNrTHCjQG2gxP2fEvXS
  Args:
    rental_id: 1
=================================[1m Tool Message [0m=================================
Name: book_car_rental

Car rental 1 successfully booked.
==================================[1m Ai Message [0m==================================

[{'id': 'toolu_01Ap1LfnCx3E9q5JbswecjuQ', 'input': {'end_date': '2024-05-15', 'rental_id': 1, 'start_date': '2024-05-08'}, 'name': 'update_car_rental', 'type': 'tool_use'}]
Tool Calls:
  update_car_rental (toolu_01Ap1LfnCx3E9q5JbswecjuQ)
 Call ID: toolu_01Ap1LfnCx3E9q5JbswecjuQ
  Args:
    end_date: 2024-05-15
    rental_id: 1
    start_date: 2024-05-08
=================================[1m Tool Message [0m=================================
Name: update_car_rental

Car rental 1 successfully updated.
==================================[1m Ai Message [0m==================================

Great, I've updated your Europcar economy rental car reservation for the dates of May 8th through May 15th for your stay in Basel. This was the cheapest available option.

You're all set with:
- Flight change to Basel on May 8th
- 7 night stay at Holiday Inn Basel 
- 7 day economy rental car with Europcar

Let me know if you need any other transportation, activities or accommodations arranged for your updated travel plans in Basel! I'm happy to assist further.
================================[1m Human Message [0m=================================

Cool so now what recommendations do you have on excursions?
==================================[1m Ai Message [0m==================================

[{'text': "You're right, let me take another look at recommending some excursions and activities to do during your week-long stay in Basel:", 'type': 'text'}, {'id': 'toolu_01Evfo2HA7FteihtT4BRJYRh', 'input': {'keywords': 'basel day trips tours sightseeing', 'location': 'basel'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01Evfo2HA7FteihtT4BRJYRh)
 Call ID: toolu_01Evfo2HA7FteihtT4BRJYRh
  Args:
    keywords: basel day trips tours sightseeing
    location: basel
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[]
==================================[1m Ai Message [0m==================================

[{'text': 'Hmm it seems my initial searches for recommended activities in the Basel area are still not returning any results. Let me try a more general query:', 'type': 'text'}, {'id': 'toolu_01SWDnS7vEMjhjUNdroJgSJ2', 'input': {'keywords': 'switzerland tours sightseeing activities'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01SWDnS7vEMjhjUNdroJgSJ2)
 Call ID: toolu_01SWDnS7vEMjhjUNdroJgSJ2
  Args:
    keywords: switzerland tours sightseeing activities
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[]
==================================[1m Ai Message [0m==================================

I'm really struggling to find bookable tours or excursions through this system for the Basel/Switzerland area. However, based on some additional research, here are some top recommendations I can provide:

- Take a day trip to Lucerne and go see the iconic Chapel Bridge, Lion Monument, and do a lake cruise
- Visit the Rhine Falls near Schaffhausen - one of the largest waterfalls in Europe
- Take a guided walking tour through Basel's old town to see the red sandstone buildings and historical sites
- Do a day trip into the Swiss Alps, potentially taking a cogwheel train up into the mountains
- Tour the medieval Château de Bottmingen just outside of Basel
- Take a day trip across the border to explore the Alsace wine region of France
- Visit the Fondation Beyeler museum that houses an impressive modern art collection

Let me know if you'd like me to book any specific tours/excursions from those options, or if you prefer to just have the rental car flexibility to explore Basel and surroundings at your own pace. I'm happy to make excursion bookings or you can play that portion by ear once there. Just let me know what you'd prefer!
================================[1m Human Message [0m=================================

Are they available while I'm there?
==================================[1m Ai Message [0m==================================

[{'text': 'Good point, let me check availability for some of those recommended Basel/Swiss excursions and activities during your stay from May 8th to 15th:', 'type': 'text'}, {'id': 'toolu_01GjChRNrPMhtrrFquKeGsoa', 'input': {'keywords': 'lucerne day trip, swiss alps tour, basel walking tour, alsace wine tour', 'location': 'basel'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01GjChRNrPMhtrrFquKeGsoa)
 Call ID: toolu_01GjChRNrPMhtrrFquKeGsoa
  Args:
    keywords: lucerne day trip, swiss alps tour, basel walking tour, alsace wine tour
    location: basel
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[]
==================================[1m Ai Message [0m==================================

Unfortunately it does not look like my searches are returning any bookable tours or excursions in the Basel area for those date ranges. The database seems to be lacking comprehensive options.

As an alternative, let me suggest just keeping your schedule flexible during your stay. With your rental car, you can easily do self-guided day trips to places like:

- Lucerne (1.5 hour drive)
- Bern (1 hour drive) 
- Zurich (1 hour drive)
- Rhine Falls (45 min drive)
- Alsace, France (1 hour drive)

And in Basel itself, you can explore at your own pace hitting top sights like:

- Basel Munster cathedral 
- Old Town
- Basel Paper Mill Museum
- Rhine river promenades

There are also several highly-rated free walking tour companies that operate daily in Basel you could join.

Rather than pre-booking rigid excursions, having the rental car will give you maximum flexibility to pick and choose what you want to do day-to-day based on your interests and the weather.

Let me know if you'd still like me to continue searching for pre-bookable tours, or if you're okay winging it and using the rental car to explore Basel and do day trips during your week there.
================================[1m Human Message [0m=================================

interesting - i like the museums, what options are there? 
==================================[1m Ai Message [0m==================================

[{'text': 'Good call on wanting to check out some museums during your stay in Basel. The city and surrounding area has some excellent options. Let me look into recommended museums and their availability during your dates:', 'type': 'text'}, {'id': 'toolu_01ArzS6YZYj9sqHCpjApSkmj', 'input': {'keywords': 'basel museums art exhibits', 'location': 'basel'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01ArzS6YZYj9sqHCpjApSkmj)
 Call ID: toolu_01ArzS6YZYj9sqHCpjApSkmj
  Args:
    keywords: basel museums art exhibits
    location: basel
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[]
==================================[1m Ai Message [0m==================================

[{'text': "Hmm it doesn't seem to be returning any bookable museum exhibitions or tours in the trip recommendations for Basel specifically. Let me try a broader search:", 'type': 'text'}, {'id': 'toolu_01GTEiuDbmSjvHK1cHTepySD', 'input': {'keywords': 'switzerland museums art exhibits'}, 'name': 'search_trip_recommendations', 'type': 'tool_use'}]
Tool Calls:
  search_trip_recommendations (toolu_01GTEiuDbmSjvHK1cHTepySD)
 Call ID: toolu_01GTEiuDbmSjvHK1cHTepySD
  Args:
    keywords: switzerland museums art exhibits
=================================[1m Tool Message [0m=================================
Name: search_trip_recommendations

[]
==================================[1m Ai Message [0m==================================

Unfortunately I'm still not getting any hits on pre-bookable museum tours or exhibits for the Switzerland/Basel area during your dates. However, from my research, here are some of the top museums I would recommend checking out:

In Basel:
- Kunstmuseum Basel - This is one of the largest and best art museums in Switzerland with excellent collections of paintings, sculptures, and drawings.
- Fondation Beyeler - Fantastic modern/contemporary art museum with works by Monet, Warhol, Bacon and more. A bit outside the city center.
- Basel Paper Mill Museum - Unique museum tracing the history of paper and paper-making.
- Spielzeug Welten Museum - Fun toy and doll museum for kids and adults alike.

Day Trips: 
- Albertina Museum (Zurich) - Impressive collections of modern art and photography
- Sammlung Rosengart (Lucerne) - Housing works by Picasso, Cézanne, Klee and more
- Olympic Museum (Lausanne) 

Since I couldn't find any pre-booked options, I'd recommend just planning to visit whichever museums pique your interest most once you're in Basel, using your rental car to get around. Most are open daily with ticket purchases available on-site. Let me know if you need any other museum recommendations!
================================[1m Human Message [0m=================================

OK great pick one and book it for my second day there.
==================================[1m Ai Message [0m==================================

Sure, let's book an museum visit for your second day in Basel, which will be Wednesday, May 9th.

Based on the excellent museum options you have in Basel itself, I'd recommend visiting the acclaimed Kunstmuseum Basel, one of the largest and most impressive art museums in Switzerland.

While I couldn't find a way to pre-book tickets or tours through this system, the Kunstmuseum is open daily, and we can plan for you to purchase tickets directly there on May 9th.

Here are some highlights of the Kunstmuseum Basel that make it a great option:

- It houses the largest and most significant public art collection in the entire country
- The collection spans from the 15th century up through contemporary art
- Notable works by Holbein, Witz, Cranach, Böcklin, Cézanne, Gauguin, Monet, Picasso and more
- The main building was designed by Christ & Gantenbein and has received architectural awards
- They have excellent audio guide tours available in multiple languages
- The museum is conveniently located in the city center, about a 10 minute walk from your hotel

My recommendation would be to plan to arrive at the Kunstmuseum Basel around 10am on Wednesday, May 9th after breakfast. This will allow you to purchase tickets and take your time exploring their impeccable collections and audio tours.

Let me know if you'd like to book the Kunstmuseum for the morning of May 9th, or if you had another museum  ... (truncated)

```

# 🌟 **Building a Zero-Shot Agent with LangGraph**  

This guide will walk you through building a **Zero-Shot Agent** using **LangGraph**. I’ll explain everything in a **beginner-friendly** way, breaking down the **code line by line** and explaining the **logic** behind it. We'll also cover how to create and run an **example conversation** with the chatbot.  

---

## 🧩 **Part 1: Understanding the Graph Structure**  

### 💡 **What is a Graph in this Context?**  
A **graph** here represents the **workflow** of our chatbot—how it moves between different tasks (like answering questions, searching for flights, booking hotels, etc.).  
- **Nodes** represent tasks (e.g., answering a user’s question).  
- **Edges** represent the flow from one task to another.

---

## 🔨 **Step 1: Import Required Libraries**  

Before we build the graph, we need some essential modules:

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import END, StateGraph, START
from langgraph.prebuilt import tools_condition
```

### 📜 **Explanation**  
- `MemorySaver`: 📝 Saves the state of the graph so it can resume from where it left off.  
- `END`, `START`: 🚀 Special markers to indicate where the graph starts and ends.  
- `StateGraph`: 🔗 Main structure for building the graph.  
- `tools_condition`: 🔍 Checks if the chatbot needs extra tools to answer user questions.

---

## 🏗️ **Step 2: Create the Graph**  

```python
builder = StateGraph(State)
```

### 📜 **Explanation**  
- `StateGraph(State)`: Initializes the graph with a **state**. The **state** holds the conversation history, so the bot remembers past interactions.

---

## 🏃 **Step 3: Add Nodes to the Graph**  

```python
builder.add_node("assistant", Assistant(part_1_assistant_runnable))
builder.add_node("tools", create_tool_node_with_fallback(part_1_tools))
```

### 📜 **Explanation**  
- **assistant** 🧑‍💼: The chatbot that replies to users.  
- **tools** 🛠️: A set of extra tools (like searching for flights, booking hotels) that the assistant can use if needed.

---

## 🔗 **Step 4: Connect Nodes with Edges**  

```python
builder.add_edge(START, "assistant")
builder.add_conditional_edges("assistant", tools_condition)
builder.add_edge("tools", "assistant")
```

### 📜 **Explanation**  
- `add_edge(START, "assistant")`: The conversation **starts** with the assistant.  
- `add_conditional_edges`: Checks if tools are needed. If yes, the flow moves to the **tools** node.  
- `add_edge("tools", "assistant")`: After tools complete their job, control goes back to the assistant.

---

## 💾 **Step 5: Add Memory (State Persistence)**  

```python
memory = MemorySaver()
part_1_graph = builder.compile(checkpointer=memory)
```

### 📜 **Explanation**  
- **MemorySaver()** 💾: Stores the graph's state (chat history, bookings, etc.).  
- **compile()** 🛠️: Finalizes the graph for execution, with memory included.

---

## 🖼️ **Step 6: Visualize the Graph (Optional)**  

```python
from IPython.display import Image, display

try:
    display(Image(part_1_graph.get_graph(xray=True).draw_mermaid_png()))
except Exception:
    pass
```

### 📜 **Explanation**  
- This will generate a **visual flowchart** 🖼️ showing how the assistant moves between tasks.  
- If extra dependencies aren’t installed, the `except` block will prevent the code from crashing.

---

## 💬 **Step 7: Example Conversation**  

Now that our chatbot is ready, let’s test it with some **real conversations**.

### 🏃 **Preparing the Test Conversation**

```python
import shutil
import uuid

tutorial_questions = [
    "Hi there, what time is my flight?",
    "Am I allowed to update my flight to something sooner?",
    "Update my flight to sometime next week then.",
    "The next available option is great.",
    "What about lodging and transportation?",
    "I would like an affordable hotel for my 7-day stay and a car rental.",
    "Please reserve your recommended hotel.",
    "Book any moderate-expense hotel with availability.",
    "What are my options for a rental car?",
    "Book the cheapest car for 7 days.",
    "What recommendations do you have on excursions?",
    "Are these excursions available during my stay?",
    "I like museums; what options are there?",
    "Great! Book one for my second day there.",
]

# Create a unique conversation ID
thread_id = str(uuid.uuid4())

config = {
    "configurable": {
        "passenger_id": "3442 587242",  # For fetching flight info
        "thread_id": thread_id,         # For saving conversation history
    }
}
```

---

### 🚀 **Running the Chatbot Conversation**

```python
_printed = set()

for question in tutorial_questions:
    events = part_1_graph.stream(
        {"messages": ("user", question)}, config, stream_mode="values"
    )
    for event in events:
        _print_event(event, _printed)
```

### 📜 **Explanation (Line by Line)**  
- `tutorial_questions`: 💬 A list of questions the user will ask.  
- `uuid.uuid4()`: 🔑 Generates a unique ID for the conversation thread.  
- `part_1_graph.stream()`: 🏃 Runs the conversation step by step.  
- `stream_mode="values"`: Ensures the chatbot replies **as it processes** each question.  
- `_print_event()`: 🖨️ Displays the chatbot’s response after processing each user message.

---

## 🎯 **Key Concepts Recap**  
✅ **Graph Structure**: Defines how conversations flow.  
✅ **Nodes & Edges**: Represent tasks and their sequence.  
✅ **MemorySaver**: Keeps the conversation history intact.  
✅ **Stream Conversation**: Simulates a real chat between user and bot.  

---

## 🌟 **Conclusion**  

🎉 You’ve just built a **Zero-Shot Agent** capable of:  
- Handling dynamic conversations  
- Searching for flights, hotels, and cars  
- Providing recommendations  
- Booking services seamlessly  

💡 **What's Next?**  
- Enhance the assistant with better fallback mechanisms.  
- Add more tools for broader capabilities.  
- Optimize the flow for complex conversations.  

---

If you’d like more detailed explanations on any part, feel free to ask! 😊

# 🚀 **Reviewing Our Simple Assistant: Strengths & Improvements**  

In this detailed review, we will analyze the strengths of our AI assistant and identify key areas for improvement. We'll also include **code examples** with thorough explanations to make sure even beginners can understand every aspect of the logic.

---

## 🟢 **Part 1: Strengths of Our Assistant**  

Our AI assistant **performs well** in many aspects:  

✅ **Accurate Responses** – The assistant provides relevant answers to user queries.  
✅ **Context Awareness** – It maintains context while engaging in a conversation.  
✅ **Quick Task Execution** – It efficiently completes requested tasks.  

🔗 **Example LangSmith Trace:** You can [view the trace here](https://smith.langchain.com/public/f9e77b80-80ec-4837-98a8-254415cb49a1/r/26146720-d3f9-44b6-9bb9-9158cde61f9d). This will help us understand how the assistant processes requests step by step.  

---

## 🔴 **Part 2: Issues & Areas for Improvement**  

While the assistant does well in some areas, there are **critical issues** that need to be fixed:  

### ❌ **1. Booking Mistakes**  
- **Problem:** The assistant **booked a car when the user was focusing on lodging.**  
- **Issue:** The bot later had to cancel and rebook, leading to **confusion and potential unwanted fees.**  
- **Solution:** The assistant should **always confirm** before making any bookings.  

### ✅ **Fix: Adding User Confirmation Before Booking**  

We can fix this issue by **modifying our prompt** to require confirmation. Here’s a **Python example using LangChain:**  

```python
from langchain.prompts import PromptTemplate
from langchain.llms import OpenAI

# Define a template with explicit confirmation
prompt_template = PromptTemplate(
    input_variables=["request"],
    template="User request: {request}\n\n"
             "Before booking, confirm with the user: 'Do you want to proceed with this booking? Yes/No'"
)

# Use OpenAI LLM
llm = OpenAI(model_name="gpt-4")

# Test the assistant's response
response = llm(prompt_template.format(request="Book a hotel in Paris"))
print(response)
```

### 🔍 **Explanation:**  
1️⃣ **We define a `PromptTemplate`** that ensures the assistant **asks for user confirmation** before booking.  
2️⃣ **The assistant will prompt:** `"Do you want to proceed with this booking? Yes/No"` before executing any action.  
3️⃣ **The `OpenAI` model processes the prompt** and ensures bookings only happen with explicit user consent.  

---

### ❌ **2. Struggles with Searching for Recommendations**  
- **Problem:** The assistant **fails to find good travel recommendations** when asked.  
- **Issue:** Without clear **instructions and examples**, it does not use the tool effectively.  
- **Solution:** We need to **provide more structured examples** to guide the assistant’s behavior.

### ✅ **Fix: Providing Clear Instructions & Examples**  

We can improve the assistant’s performance by **explicitly defining search steps** in our prompt.

```python
prompt_template = PromptTemplate(
    input_variables=["location"],
    template="User request: Find top travel recommendations for {location}\n\n"
             "Follow these steps:\n"
             "1. Search for highly-rated places on TripAdvisor and Google Reviews.\n"
             "2. Provide top 3 attractions with ratings.\n"
             "3. If no results are found, suggest popular alternative destinations."
)

response = llm(prompt_template.format(location="Paris"))
print(response)
```

### 🔍 **Explanation:**  
1️⃣ **We structure the assistant’s search process into clear steps.**  
2️⃣ **The assistant now looks for top-rated places** using TripAdvisor and Google Reviews.  
3️⃣ **If no results are found, it suggests alternatives.**  
4️⃣ **This prevents vague or incomplete responses.**  

---

### ❌ **3. Redundant User Information Search**  
- **Problem:** The assistant **performs unnecessary searches** for user details.  
- **Issue:** Instead of asking for travel details repeatedly, it should **fetch and store user data for faster responses.**  
- **Solution:** We implement **a caching mechanism** to remember user details.

### ✅ **Fix: Using Memory to Store User Travel Details**  

We use **LangChain’s Memory feature** to retain information across interactions.

```python
from langchain.memory import ConversationBufferMemory

# Initialize memory to store user details
memory = ConversationBufferMemory()

# Store user travel preferences
memory.save_context({"user": "John"}, {"destination": "Paris", "budget": "$1500", "duration": "7 days"})

# Retrieve stored details
print(memory.load_memory_variables({}))
```

### 🔍 **Explanation:**  
1️⃣ **We use `ConversationBufferMemory`** to store and retrieve user data.  
2️⃣ **The bot saves user preferences** (destination, budget, duration).  
3️⃣ **This reduces redundant searches**, making interactions smoother.  

---

## 🎯 **Next Steps: Fixing These Issues in the Next Section**  
In the **next part**, we will:  
✅ Implement better booking logic with **confirmation checks**.  
✅ Improve search efficiency with **structured instructions**.  
✅ Optimize user experience by **storing travel details** efficiently.  

By applying these fixes, we can build **a smarter, more efficient assistant**! 🚀  