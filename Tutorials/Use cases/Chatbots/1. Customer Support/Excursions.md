# Excursions¶
Finally, define some tools to let the user search for things to do (and make reservations) once they arrive.

```python
@tool
def search_trip_recommendations(
    location: Optional[str] = None,
    name: Optional[str] = None,
    keywords: Optional[str] = None,
) -> list[dict]:
    """
    Search for trip recommendations based on location, name, and keywords.

    Args:
        location (Optional[str]): The location of the trip recommendation. Defaults to None.
        name (Optional[str]): The name of the trip recommendation. Defaults to None.
        keywords (Optional[str]): The keywords associated with the trip recommendation. Defaults to None.

    Returns:
        list[dict]: A list of trip recommendation dictionaries matching the search criteria.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    query = "SELECT * FROM trip_recommendations WHERE 1=1"
    params = []

    if location:
        query += " AND location LIKE ?"
        params.append(f"%{location}%")
    if name:
        query += " AND name LIKE ?"
        params.append(f"%{name}%")
    if keywords:
        keyword_list = keywords.split(",")
        keyword_conditions = " OR ".join(["keywords LIKE ?" for _ in keyword_list])
        query += f" AND ({keyword_conditions})"
        params.extend([f"%{keyword.strip()}%" for keyword in keyword_list])

    cursor.execute(query, params)
    results = cursor.fetchall()

    conn.close()

    return [
        dict(zip([column[0] for column in cursor.description], row)) for row in results
    ]


@tool
def book_excursion(recommendation_id: int) -> str:
    """
    Book a excursion by its recommendation ID.

    Args:
        recommendation_id (int): The ID of the trip recommendation to book.

    Returns:
        str: A message indicating whether the trip recommendation was successfully booked or not.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute(
        "UPDATE trip_recommendations SET booked = 1 WHERE id = ?", (recommendation_id,)
    )
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Trip recommendation {recommendation_id} successfully booked."
    else:
        conn.close()
        return f"No trip recommendation found with ID {recommendation_id}."


@tool
def update_excursion(recommendation_id: int, details: str) -> str:
    """
    Update a trip recommendation's details by its ID.

    Args:
        recommendation_id (int): The ID of the trip recommendation to update.
        details (str): The new details of the trip recommendation.

    Returns:
        str: A message indicating whether the trip recommendation was successfully updated or not.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute(
        "UPDATE trip_recommendations SET details = ? WHERE id = ?",
        (details, recommendation_id),
    )
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Trip recommendation {recommendation_id} successfully updated."
    else:
        conn.close()
        return f"No trip recommendation found with ID {recommendation_id}."


@tool
def cancel_excursion(recommendation_id: int) -> str:
    """
    Cancel a trip recommendation by its ID.

    Args:
        recommendation_id (int): The ID of the trip recommendation to cancel.

    Returns:
        str: A message indicating whether the trip recommendation was successfully cancelled or not.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute(
        "UPDATE trip_recommendations SET booked = 0 WHERE id = ?", (recommendation_id,)
    )
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Trip recommendation {recommendation_id} successfully cancelled."
    else:
        conn.close()
        return f"No trip recommendation found with ID {recommendation_id}."
```


# ✈️ **Excursions Management System**  

This guide will explain **excursion management** with Python in a simple, beginner-friendly way. We will cover how to:  
1️⃣ Search for trips  
2️⃣ Book excursions  
3️⃣ Update excursion details  
4️⃣ Cancel excursions  

We'll break down **real-world applications**, use **clear examples**, and provide **detailed code explanations** so you understand **every line**.  

---

## 🌍 **Why Is Excursion Management Important?**  
Imagine you're building a **travel app** like **TripAdvisor** or **Booking.com**, where users not only book hotels but also **explore activities** like sightseeing tours, adventure sports, and cultural experiences.  

This system helps users:  
✅ Find things to do in specific locations.  
✅ Book activities for their trip.  
✅ Modify or cancel their bookings.  

---

## 🛠️ **Key Concepts**  

- **SQLite Database**: We'll use SQLite, a lightweight database, to store and manage data.  
- **SQL Queries**: We'll write SQL commands (`SELECT`, `UPDATE`) to interact with the database.  
- **Dynamic Search**: Users can search based on location, name, or keywords.  
- **CRUD Operations**: Our code will perform **C**reate, **R**ead, **U**pdate, and **D**elete-like operations.  

---

## 🔍 **1. Search for Trip Recommendations**  

### 💡 **Purpose**  
This function helps users **find trips** based on:  
- **Location**  
- **Name**  
- **Keywords** (e.g., "hiking", "museum", "beach")  

### 💻 **Code and Explanation**  

```python
@tool
def search_trip_recommendations(
    location: Optional[str] = None,
    name: Optional[str] = None,
    keywords: Optional[str] = None,
) -> list[dict]:
    """
    Search for trip recommendations based on location, name, and keywords.
    """
    # 🔗 Connect to the SQLite database
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    # 📝 Base SQL query
    query = "SELECT * FROM trip_recommendations WHERE 1=1"
    params = []

    # 🌎 Filter by location if provided
    if location:
        query += " AND location LIKE ?"
        params.append(f"%{location}%")

    # 🏷️ Filter by trip name
    if name:
        query += " AND name LIKE ?"
        params.append(f"%{name}%")

    # 🔑 Filter by keywords
    if keywords:
        keyword_list = keywords.split(",")
        keyword_conditions = " OR ".join(["keywords LIKE ?" for _ in keyword_list])
        query += f" AND ({keyword_conditions})"
        params.extend([f"%{keyword.strip()}%" for keyword in keyword_list])

    # 🚀 Execute the final query
    cursor.execute(query, params)
    results = cursor.fetchall()

    # 🔒 Close the connection
    conn.close()

    # 🔄 Convert results to a list of dictionaries for easy use
    return [
        dict(zip([column[0] for column in cursor.description], row)) for row in results
    ]
```

---

### 📝 **Line-by-Line Explanation:**  

- **Database Connection**:  
  ```python
  conn = sqlite3.connect(db)
  cursor = conn.cursor()
  ```  
  - Connects to the database file `db`.  
  - The `cursor` allows us to execute SQL commands.  

- **Base Query**:  
  ```python
  query = "SELECT * FROM trip_recommendations WHERE 1=1"
  ```  
  - `WHERE 1=1` is a **trick** to simplify adding more conditions (`AND ...`).  

- **Dynamic Filters**:  
  ```python
  if location:
      query += " AND location LIKE ?"
      params.append(f"%{location}%")
  ```  
  - If a user provides a location, we add it to the query.  
  - `%{location}%` means **"contains this value"** (case-insensitive search).  

- **Keyword Matching**:  
  ```python
  if keywords:
      keyword_list = keywords.split(",")
      keyword_conditions = " OR ".join(["keywords LIKE ?" for _ in keyword_list])
      query += f" AND ({keyword_conditions})"
      params.extend([f"%{keyword.strip()}%" for keyword in keyword_list])
  ```  
  - Splits the `keywords` string by commas and searches for **any** of them in the database.  

---

### 🌟 **Real-World Example**  
If you're planning a trip to **Paris**, you might search for:  
```python
search_trip_recommendations(location="Paris", keywords="museum,art")
```
This would return trips in Paris related to **museums** or **art exhibitions**.

---

## 🏝️ **2. Book an Excursion**  

### 💡 **Purpose**  
Once a user picks an excursion, we need to **book it** (mark it as reserved in the database).  

---

### 💻 **Code and Explanation**  

```python
@tool
def book_excursion(recommendation_id: int) -> str:
    """
    Book an excursion by its recommendation ID.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    # ✅ Update 'booked' status to 1 (True)
    cursor.execute(
        "UPDATE trip_recommendations SET booked = 1 WHERE id = ?", (recommendation_id,)
    )
    conn.commit()

    # 📢 Check if the booking was successful
    if cursor.rowcount > 0:
        conn.close()
        return f"Trip recommendation {recommendation_id} successfully booked."
    else:
        conn.close()
        return f"No trip recommendation found with ID {recommendation_id}."
```

---

### 📝 **Key Points**  
- **UPDATE Statement**: Changes the `booked` field to `1` (**True**) for the given trip.  
- **`rowcount` Check**: If `rowcount > 0`, it means the booking was successful.  

---

### 🌟 **Real-World Example**  
Imagine you're booking a **boat tour** in **Venice** with ID `5`:  
```python
print(book_excursion(5))
```
If successful, it returns:  
```
Trip recommendation 5 successfully booked.
```

---

## 📝 **3. Update Excursion Details**  

### 💡 **Purpose**  
Allows users to **update details** of a booked trip (e.g., changing time or description).  

---

### 💻 **Code and Explanation**  

```python
@tool
def update_excursion(recommendation_id: int, details: str) -> str:
    """
    Update a trip recommendation's details by its ID.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    # 📝 Update trip details
    cursor.execute(
        "UPDATE trip_recommendations SET details = ? WHERE id = ?",
        (details, recommendation_id),
    )
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Trip recommendation {recommendation_id} successfully updated."
    else:
        conn.close()
        return f"No trip recommendation found with ID {recommendation_id}."
```

---

### 🌟 **Example Usage**  
Updating a trip with **new details**:  
```python
update_excursion(5, "Updated time: 3 PM. Includes lunch.")
```

---

## ❌ **4. Cancel an Excursion**  

### 💡 **Purpose**  
Lets users **cancel** their reservation if their plans change.  

---

### 💻 **Code and Explanation**  

```python
@tool
def cancel_excursion(recommendation_id: int) -> str:
    """
    Cancel a trip recommendation by its ID.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    # 🚫 Set 'booked' status to 0 (False)
    cursor.execute(
        "UPDATE trip_recommendations SET booked = 0 WHERE id = ?", (recommendation_id,)
    )
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Trip recommendation {recommendation_id} successfully cancelled."
    else:
        conn.close()
        return f"No trip recommendation found with ID {recommendation_id}."
```

---

### 🌟 **Example Usage**  
```python
cancel_excursion(5)
```
If successful, it returns:  
```
Trip recommendation 5 successfully cancelled.
```

---

## 🌈 **Real-World Application of This System**  
Such excursion management systems are used in:  
- **Travel Booking Apps** like Airbnb Experiences or Viator.  
- **Tourism Websites** for city sightseeing or guided tours.  
- **Hotel Concierge Services** offering personalized local activities.  

---

## 🔑 **Key Takeaways**  
- We learned to search, book, update, and cancel trips using **Python** and **SQLite**.  
- The dynamic search handles multiple filters like **location**, **name**, and **keywords**.  
- Booking and cancellation are handled via simple SQL **UPDATE** commands.  

---

💬 **Have any questions or need more real-world scenarios? Let me know!** 😊