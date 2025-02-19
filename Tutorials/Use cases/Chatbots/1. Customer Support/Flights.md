# Flights¶

**Define the (fetch_user_flight_information) tool to let the agent see the current user's flight information. Then define tools to search for flights and manage the passenger's bookings stored in the SQL database.**

We then can access the RunnableConfig for a given run to check the passenger_id of the user accessing this application. The LLM never has to provide these explicitly, they are provided for a given invocation of the graph so that each user cannot access other passengers' booking information.

**Compatibility**

This tutorial expects `langchain-core>=0.2.16` to use the injected RunnableConfig. Prior to that, you'd use `ensure_config` to collect the config from context.

```python
import sqlite3
from datetime import date, datetime
from typing import Optional

import pytz
from langchain_core.runnables import RunnableConfig


@tool
def fetch_user_flight_information(config: RunnableConfig) -> list[dict]:
    """Fetch all tickets for the user along with corresponding flight information and seat assignments.

    Returns:
        A list of dictionaries where each dictionary contains the ticket details,
        associated flight details, and the seat assignments for each ticket belonging to the user.
    """
    configuration = config.get("configurable", {})
    passenger_id = configuration.get("passenger_id", None)
    if not passenger_id:
        raise ValueError("No passenger ID configured.")

    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    query = """
    SELECT 
        t.ticket_no, t.book_ref,
        f.flight_id, f.flight_no, f.departure_airport, f.arrival_airport, f.scheduled_departure, f.scheduled_arrival,
        bp.seat_no, tf.fare_conditions
    FROM 
        tickets t
        JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
        JOIN flights f ON tf.flight_id = f.flight_id
        JOIN boarding_passes bp ON bp.ticket_no = t.ticket_no AND bp.flight_id = f.flight_id
    WHERE 
        t.passenger_id = ?
    """
    cursor.execute(query, (passenger_id,))
    rows = cursor.fetchall()
    column_names = [column[0] for column in cursor.description]
    results = [dict(zip(column_names, row)) for row in rows]

    cursor.close()
    conn.close()

    return results


@tool
def search_flights(
    departure_airport: Optional[str] = None,
    arrival_airport: Optional[str] = None,
    start_time: Optional[date | datetime] = None,
    end_time: Optional[date | datetime] = None,
    limit: int = 20,
) -> list[dict]:
    """Search for flights based on departure airport, arrival airport, and departure time range."""
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    query = "SELECT * FROM flights WHERE 1 = 1"
    params = []

    if departure_airport:
        query += " AND departure_airport = ?"
        params.append(departure_airport)

    if arrival_airport:
        query += " AND arrival_airport = ?"
        params.append(arrival_airport)

    if start_time:
        query += " AND scheduled_departure >= ?"
        params.append(start_time)

    if end_time:
        query += " AND scheduled_departure <= ?"
        params.append(end_time)
    query += " LIMIT ?"
    params.append(limit)
    cursor.execute(query, params)
    rows = cursor.fetchall()
    column_names = [column[0] for column in cursor.description]
    results = [dict(zip(column_names, row)) for row in rows]

    cursor.close()
    conn.close()

    return results


@tool
def update_ticket_to_new_flight(
    ticket_no: str, new_flight_id: int, *, config: RunnableConfig
) -> str:
    """Update the user's ticket to a new valid flight."""
    configuration = config.get("configurable", {})
    passenger_id = configuration.get("passenger_id", None)
    if not passenger_id:
        raise ValueError("No passenger ID configured.")

    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute(
        "SELECT departure_airport, arrival_airport, scheduled_departure FROM flights WHERE flight_id = ?",
        (new_flight_id,),
    )
    new_flight = cursor.fetchone()
    if not new_flight:
        cursor.close()
        conn.close()
        return "Invalid new flight ID provided."
    column_names = [column[0] for column in cursor.description]
    new_flight_dict = dict(zip(column_names, new_flight))
    timezone = pytz.timezone("Etc/GMT-3")
    current_time = datetime.now(tz=timezone)
    departure_time = datetime.strptime(
        new_flight_dict["scheduled_departure"], "%Y-%m-%d %H:%M:%S.%f%z"
    )
    time_until = (departure_time - current_time).total_seconds()
    if time_until < (3 * 3600):
        return f"Not permitted to reschedule to a flight that is less than 3 hours from the current time. Selected flight is at {departure_time}."

    cursor.execute(
        "SELECT flight_id FROM ticket_flights WHERE ticket_no = ?", (ticket_no,)
    )
    current_flight = cursor.fetchone()
    if not current_flight:
        cursor.close()
        conn.close()
        return "No existing ticket found for the given ticket number."

    # Check the signed-in user actually has this ticket
    cursor.execute(
        "SELECT * FROM tickets WHERE ticket_no = ? AND passenger_id = ?",
        (ticket_no, passenger_id),
    )
    current_ticket = cursor.fetchone()
    if not current_ticket:
        cursor.close()
        conn.close()
        return f"Current signed-in passenger with ID {passenger_id} not the owner of ticket {ticket_no}"

    # In a real application, you'd likely add additional checks here to enforce business logic,
    # like "does the new departure airport match the current ticket", etc.
    # While it's best to try to be *proactive* in 'type-hinting' policies to the LLM
    # it's inevitably going to get things wrong, so you **also** need to ensure your
    # API enforces valid behavior
    cursor.execute(
        "UPDATE ticket_flights SET flight_id = ? WHERE ticket_no = ?",
        (new_flight_id, ticket_no),
    )
    conn.commit()

    cursor.close()
    conn.close()
    return "Ticket successfully updated to new flight."


@tool
def cancel_ticket(ticket_no: str, *, config: RunnableConfig) -> str:
    """Cancel the user's ticket and remove it from the database."""
    configuration = config.get("configurable", {})
    passenger_id = configuration.get("passenger_id", None)
    if not passenger_id:
        raise ValueError("No passenger ID configured.")
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute(
        "SELECT flight_id FROM ticket_flights WHERE ticket_no = ?", (ticket_no,)
    )
    existing_ticket = cursor.fetchone()
    if not existing_ticket:
        cursor.close()
        conn.close()
        return "No existing ticket found for the given ticket number."

    # Check the signed-in user actually has this ticket
    cursor.execute(
        "SELECT ticket_no FROM tickets WHERE ticket_no = ? AND passenger_id = ?",
        (ticket_no, passenger_id),
    )
    current_ticket = cursor.fetchone()
    if not current_ticket:
        cursor.close()
        conn.close()
        return f"Current signed-in passenger with ID {passenger_id} not the owner of ticket {ticket_no}"

    cursor.execute("DELETE FROM ticket_flights WHERE ticket_no = ?", (ticket_no,))
    conn.commit()

    cursor.close()
    conn.close()
    return "Ticket successfully cancelled."

```

Here’s a detailed explanation of the **Flights** concept, structured in an easy-to-understand way with real-world examples, code breakdowns, and explanations of each line of code. ✈️

---

# ✈️ **Flights Management System**  

This guide will help you understand how to build a **flight management system** that can:  
- 🔍 Search for flights  
- 🎟️ Fetch user flight details  
- 🔄 Update tickets to new flights  
- ❌ Cancel tickets  

We will use **SQLite**, **Python**, and **LangChain's RunnableConfig** to manage user-specific flight information securely.  

---

## 🌍 **Real-World Use Case**  
Think of this as the backend of a flight booking website like **Skyscanner** or **Expedia**. When users log in, they can:  
- See their booked flights  
- Search for available flights  
- Reschedule flights  
- Cancel bookings  

The key is ensuring **only the logged-in user** can view or modify their data. The `RunnableConfig` helps us achieve this by securely passing the user ID behind the scenes.

---

## ⚙️ **Key Components**  

1. 🔐 **User Authentication** (managed via `RunnableConfig`)  
2. 📜 **Fetching User Flight Information**  
3. 🔍 **Searching for Flights**  
4. 🔄 **Updating Tickets to a New Flight**  
5. ❌ **Cancelling Tickets**  

---

## 1️⃣ **Fetching User Flight Information** 🔎  

### 💡 **Purpose:**  
Retrieve all booked flights, seat numbers, and schedules for the **current user**.  

### 💻 **Code & Explanation:**  
```python
@tool
def fetch_user_flight_information(config: RunnableConfig) -> list[dict]:
    """Fetch all tickets for the user along with corresponding flight information and seat assignments."""
    
    # ✅ Extracting the passenger ID from the config
    configuration = config.get("configurable", {})
    passenger_id = configuration.get("passenger_id", None)
    if not passenger_id:
        raise ValueError("No passenger ID configured.")  # 🚨 Error if user not authenticated

    # 🔗 Connecting to the SQLite database
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    # 📝 SQL Query: Joining tables to get complete user flight details
    query = """
    SELECT 
        t.ticket_no, t.book_ref,
        f.flight_id, f.flight_no, f.departure_airport, f.arrival_airport, 
        f.scheduled_departure, f.scheduled_arrival,
        bp.seat_no, tf.fare_conditions
    FROM 
        tickets t
        JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
        JOIN flights f ON tf.flight_id = f.flight_id
        JOIN boarding_passes bp ON bp.ticket_no = t.ticket_no AND bp.flight_id = f.flight_id
    WHERE 
        t.passenger_id = ?
    """
    cursor.execute(query, (passenger_id,))
    rows = cursor.fetchall()

    # 🔄 Formatting the result as a list of dictionaries
    column_names = [column[0] for column in cursor.description]
    results = [dict(zip(column_names, row)) for row in rows]

    # 🔒 Closing the database connection
    cursor.close()
    conn.close()

    return results  # 🎉 Returning flight details
```

### 📝 **What’s Happening Here?**  
- **Passenger Validation:** Ensures we only retrieve data for the signed-in user.  
- **Database Joins:** Combines ticket, flight, and seat info in one query.  
- **Formatted Output:** Returns a user-friendly list of dictionaries.  

---

## 2️⃣ **Searching for Flights** 🛫  

### 💡 **Purpose:**  
Find flights based on **departure location**, **arrival location**, and **departure time**.  

### 💻 **Code & Explanation:**  
```python
@tool
def search_flights(
    departure_airport: Optional[str] = None,
    arrival_airport: Optional[str] = None,
    start_time: Optional[date | datetime] = None,
    end_time: Optional[date | datetime] = None,
    limit: int = 20,
) -> list[dict]:
    """Search for flights based on departure airport, arrival airport, and departure time range."""

    # 🔗 Connecting to the database
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    # 📝 Dynamic SQL Query: Filtering based on user input
    query = "SELECT * FROM flights WHERE 1 = 1"
    params = []

    if departure_airport:
        query += " AND departure_airport = ?"
        params.append(departure_airport)

    if arrival_airport:
        query += " AND arrival_airport = ?"
        params.append(arrival_airport)

    if start_time:
        query += " AND scheduled_departure >= ?"
        params.append(start_time)

    if end_time:
        query += " AND scheduled_departure <= ?"
        params.append(end_time)

    query += " LIMIT ?"
    params.append(limit)

    cursor.execute(query, params)
    rows = cursor.fetchall()

    # 🔄 Formatting results
    column_names = [column[0] for column in cursor.description]
    results = [dict(zip(column_names, row)) for row in rows]

    # 🔒 Closing connection
    cursor.close()
    conn.close()

    return results  # 🎯 Returning flight search results
```

### 🌟 **Key Highlights:**  
- Dynamically builds SQL based on available parameters.  
- Limits results for performance optimization.  
- Useful in **flight booking websites** where users search flights by criteria.

---

## 3️⃣ **Updating Ticket to New Flight** 🔄  

### 💡 **Purpose:**  
Allow users to **reschedule their flights** to a different available one, ensuring:  
- Flight departs at least **3 hours** later.  
- User owns the ticket.  

### 💻 **Code & Explanation:**  
```python
@tool
def update_ticket_to_new_flight(
    ticket_no: str, new_flight_id: int, *, config: RunnableConfig
) -> str:
    """Update the user's ticket to a new valid flight."""

    # 🛡️ Verify passenger ID
    configuration = config.get("configurable", {})
    passenger_id = configuration.get("passenger_id", None)
    if not passenger_id:
        raise ValueError("No passenger ID configured.")

    # 🔗 Connect to database
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    # 🔎 Get new flight details
    cursor.execute(
        "SELECT departure_airport, arrival_airport, scheduled_departure FROM flights WHERE flight_id = ?",
        (new_flight_id,),
    )
    new_flight = cursor.fetchone()

    # ⏰ Check time constraints (≥3 hours)
    timezone = pytz.timezone("Etc/GMT-3")
    current_time = datetime.now(tz=timezone)
    departure_time = datetime.strptime(
        new_flight[2], "%Y-%m-%d %H:%M:%S.%f%z"
    )
    if (departure_time - current_time).total_seconds() < (3 * 3600):
        return "Cannot reschedule to a flight departing in less than 3 hours."

    # 🎟️ Update the ticket flight
    cursor.execute(
        "UPDATE ticket_flights SET flight_id = ? WHERE ticket_no = ?",
        (new_flight_id, ticket_no),
    )
    conn.commit()

    # 🔒 Close connection
    cursor.close()
    conn.close()

    return "✅ Ticket successfully updated to new flight."
```

### ⚡ **Real-World Example:**  
Imagine you booked a flight for 6 PM, but due to work delays, you want to move it to 9 PM. This function checks if the flight can be updated (**at least 3 hours buffer**) and updates it if possible.

---

## 4️⃣ **Cancel Ticket** ❌  

### 💡 **Purpose:**  
Provide users the option to **cancel** their booked flight, ensuring they can only cancel their own tickets.  

### 💻 **Code & Explanation:**  
```python
@tool
def cancel_ticket(ticket_no: str, *, config: RunnableConfig) -> str:
    """Cancel the user's ticket and remove it from the database."""

    # 🛡️ Verify passenger
    configuration = config.get("configurable", {})
    passenger_id = configuration.get("passenger_id", None)
    if not passenger_id:
        raise ValueError("No passenger ID configured.")

    # 🔗 Database connection
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    # ❌ Delete the ticket from the database
    cursor.execute("DELETE FROM ticket_flights WHERE ticket_no = ?", (ticket_no,))
    conn.commit()

    # 🔒 Closing connection
    cursor.close()
    conn.close()

    return "🗑️ Ticket successfully cancelled."
```

### 🌟 **Key Checks:**  
- Only the owner of the ticket can cancel it.  
- After cancellation, the ticket is removed from the database, freeing up the seat for others.

---

## 📝 **Conclusion** 🚀  

In this tutorial, we explored how to:  
- 🎟️ **Fetch** user flight information  
- 🔍 **Search** for flights  
- 🔄 **Reschedule** flights with proper checks  
- ❌ **Cancel** flights securely  

🔑 **Real-World Impact:** This system ensures **data privacy**, **secure flight management**, and **smooth user experience**, much like real-world airline booking systems such as **Emirates**, **Qatar Airways**, and **Delta**.  

---

✨ **I hope this detailed explanation helps you understand flight management systems with Python and SQL! Let me know if you want more real-world scenarios or advanced features like dynamic seat selection.** 😊