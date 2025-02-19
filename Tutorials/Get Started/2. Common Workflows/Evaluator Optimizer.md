# 🌟 **Evaluator-Optimizer Workflow Explained**  

The **Evaluator-Optimizer** workflow is a powerful pattern in AI systems that allows iterative improvement of results. In this guide, we will explain the concept step by step, show real-world applications, provide code examples, and explain each line of the code.

---

## 💡 **What is the Evaluator-Optimizer Workflow?**  

In this workflow:  
1. **Generator**: A model generates an initial response based on input.  
2. **Evaluator**: Another model evaluates the generated response, gives feedback, and suggests improvements.  
3. **Loop**: This process continues until the output meets predefined criteria.

---

## 📚 **When to Use Evaluator-Optimizer Workflow?**  
This workflow is useful when:  
- You have **clear evaluation criteria** (e.g., correctness, humor, relevance).  
- **Iterative improvement** adds value (e.g., improving jokes, refining answers, or enhancing designs).  
- **Feedback can be provided** by the model itself or a human.

---

## 🌎 **Real-World Applications**  
- ✅ **Content Creation**: Refining blog posts, jokes, or stories.  
- 🎬 **Script Writing**: Polishing movie scripts with iterative feedback.  
- 📝 **Essay Grading**: Providing feedback for students to improve essays.  
- 💬 **Chatbots**: Enhancing chatbot responses for better customer service.

---

## 🛠 **Code Example (with Detailed Explanation)**  

Let's break down a Python example using LangChain's `Evaluator-Optimizer` concept.

---

### 🔄 **Step 1: Define Feedback Schema**  
This ensures the feedback from the evaluator is structured.

```python
from pydantic import BaseModel, Field
from typing import Literal

# Schema for feedback
class Feedback(BaseModel):
    grade: Literal["funny", "not funny"] = Field(
        description="Decide if the joke is funny or not."
    )
    feedback: str = Field(
        description="If the joke is not funny, provide feedback on how to improve it."
    )
```
### 📝 **Explanation**  
- `BaseModel`: Defines the structure of our feedback using Pydantic.  
- `grade`: The evaluator will classify the joke as **funny** or **not funny**.  
- `feedback`: If the joke isn’t funny, suggestions for improvement will be provided.

---

### 🔄 **Step 2: Augment LLM with Feedback Schema**  

```python
evaluator = llm.with_structured_output(Feedback)
```
### 📝 **Explanation**  
- `with_structured_output(Feedback)`: Ensures the output matches the `Feedback` structure defined earlier.

---

### ⚡ **Step 3: Generate Jokes with Feedback Consideration**  

```python
@task
def llm_call_generator(topic: str, feedback: Feedback):
    """LLM generates a joke"""
    if feedback:
        msg = llm.invoke(
            f"Write a joke about {topic} but take into account the feedback: {feedback}"
        )
    else:
        msg = llm.invoke(f"Write a joke about {topic}")
    return msg.content
```
### 📝 **Explanation**  
- **Purpose**: To generate a joke based on the topic.  
- **Logic**:  
  - If there’s feedback, generate a joke with the feedback considered.  
  - If not, just generate a basic joke.

---

### 🔍 **Step 4: Evaluate the Joke**  

```python
@task
def llm_call_evaluator(joke: str):
    """LLM evaluates the joke"""
    feedback = evaluator.invoke(f"Grade the joke {joke}")
    return feedback
```
### 📝 **Explanation**  
- The evaluator grades the joke and provides feedback if it’s not funny.

---

### 🔄 **Step 5: Optimizer Loop**  

```python
@entrypoint()
def optimizer_workflow(topic: str):
    feedback = None
    while True:
        joke = llm_call_generator(topic, feedback).result()
        feedback = llm_call_evaluator(joke).result()
        if feedback.grade == "funny":
            break
    return joke
```
### 📝 **Explanation**  
- **feedback = None**: Initially, there’s no feedback.  
- **while True**: The loop runs until the joke is "funny."  
- **llm_call_generator**: Generates a joke with feedback.  
- **llm_call_evaluator**: Evaluates the joke.  
- **break**: Ends the loop if the joke is funny.

---

### 🚀 **Step 6: Running the Workflow**  

```python
# Invoke
for step in optimizer_workflow.stream("Cats", stream_mode="updates"):
    print(step)
    print("\n")
```
### 📝 **Explanation**  
- **optimizer_workflow.stream("Cats")**: Starts the workflow with "Cats" as the topic.  
- **stream_mode="updates"**: Prints progress at each iteration.

---

## 🎉 **Output Example:**  
```
First attempt joke: "Why don’t cats play poker in the jungle? Too many cheetahs."  
Evaluator feedback: "Not funny—too common. Try something unique."  

Second attempt joke: "What do you call a pile of kittens? A meowtain."  
Evaluator feedback: "Funnier but could be wittier."  

Third attempt joke: "Why did the cat get a job? Because it wanted to be purr-suasive in sales!"  
Evaluator feedback: "Funny."  
```

---

## 🌟 **Key Takeaways**  
- **Iterative Process**: The generator and evaluator work together until the best result is achieved.  
- **Flexible Applications**: Can be used for various creative and technical tasks.  
- **Clear Criteria**: Essential for evaluating outputs effectively.  

---

💬 *Let me know if you’d like more advanced scenarios or deeper insights into LangChain integrations!*



# Code of Functional API (beta)
```python
# Schema for structured output to use in evaluation
class Feedback(BaseModel):
    grade: Literal["funny", "not funny"] = Field(
        description="Decide if the joke is funny or not.",
    )
    feedback: str = Field(
        description="If the joke is not funny, provide feedback on how to improve it.",
    )


# Augment the LLM with schema for structured output
evaluator = llm.with_structured_output(Feedback)


# Nodes
@task
def llm_call_generator(topic: str, feedback: Feedback):
    """LLM generates a joke"""
    if feedback:
        msg = llm.invoke(
            f"Write a joke about {topic} but take into account the feedback: {feedback}"
        )
    else:
        msg = llm.invoke(f"Write a joke about {topic}")
    return msg.content


@task
def llm_call_evaluator(joke: str):
    """LLM evaluates the joke"""
    feedback = evaluator.invoke(f"Grade the joke {joke}")
    return feedback


@entrypoint()
def optimizer_workflow(topic: str):
    feedback = None
    while True:
        joke = llm_call_generator(topic, feedback).result()
        feedback = llm_call_evaluator(joke).result()
        if feedback.grade == "funny":
            break

    return joke

# Invoke
for step in optimizer_workflow.stream("Cats", stream_mode="updates"):
    print(step)
    print("\n")

```

# Complete Code of Graph API
```python
# Graph state
class State(TypedDict):
    joke: str
    topic: str
    feedback: str
    funny_or_not: str


# Schema for structured output to use in evaluation
class Feedback(BaseModel):
    grade: Literal["funny", "not funny"] = Field(
        description="Decide if the joke is funny or not.",
    )
    feedback: str = Field(
        description="If the joke is not funny, provide feedback on how to improve it.",
    )


# Augment the LLM with schema for structured output
evaluator = llm.with_structured_output(Feedback)


# Nodes
def llm_call_generator(state: State):
    """LLM generates a joke"""

    if state.get("feedback"):
        msg = llm.invoke(
            f"Write a joke about {state['topic']} but take into account the feedback: {state['feedback']}"
        )
    else:
        msg = llm.invoke(f"Write a joke about {state['topic']}")
    return {"joke": msg.content}


def llm_call_evaluator(state: State):
    """LLM evaluates the joke"""

    grade = evaluator.invoke(f"Grade the joke {state['joke']}")
    return {"funny_or_not": grade.grade, "feedback": grade.feedback}


# Conditional edge function to route back to joke generator or end based upon feedback from the evaluator
def route_joke(state: State):
    """Route back to joke generator or end based upon feedback from the evaluator"""

    if state["funny_or_not"] == "funny":
        return "Accepted"
    elif state["funny_or_not"] == "not funny":
        return "Rejected + Feedback"


# Build workflow
optimizer_builder = StateGraph(State)

# Add the nodes
optimizer_builder.add_node("llm_call_generator", llm_call_generator)
optimizer_builder.add_node("llm_call_evaluator", llm_call_evaluator)

# Add edges to connect nodes
optimizer_builder.add_edge(START, "llm_call_generator")
optimizer_builder.add_edge("llm_call_generator", "llm_call_evaluator")
optimizer_builder.add_conditional_edges(
    "llm_call_evaluator",
    route_joke,
    {  # Name returned by route_joke : Name of next node to visit
        "Accepted": END,
        "Rejected + Feedback": "llm_call_generator",
    },
)

# Compile the workflow
optimizer_workflow = optimizer_builder.compile()

# Show the workflow
display(Image(optimizer_workflow.get_graph().draw_mermaid_png()))

# Invoke
state = optimizer_workflow.invoke({"topic": "Cats"})
print(state["joke"])

```