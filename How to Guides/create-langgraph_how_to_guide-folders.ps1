$folders = @("Graph_API_Basics", "Fine-grained_Control", "Persistence", "Memory", "Human-in-the-loop", "Time_Travel", "Streaming", "Tool_calling", "Subgraphs", "Multi-agent", "State_Management", "Other", "Prebuilt_ReAct_Agent", "LangGraph_Platform", "Application_Structure", "Deployment", "Authentication_Access_Control", "Assistants", "Threads", "Runs", "Webhooks", "Cron_Jobs", "LangGraph_Studio", "Troubleshooting")

$files = @{
    "Graph_API_Basics" = @("update_graph_state.md", "sequence_of_steps.md", "parallel_execution.md", "loops_with_recursion.md", "visualize_graph.md")
    "Fine-grained_Control" = @("map_reduce_branches.md", "update_state_jump_nodes.md", "runtime_configuration.md", "node_retries.md", "return_state_recursion_limit.md")
    "Persistence" = @("long_term_memory.md", "checkpointing.md", "state_persistence.md")
    "Memory" = @("memory_management.md", "context_window.md", "short_term_memory.md")
    "Human-in-the-loop" = @("manual_decision.md", "feedback_loop.md", "validation_steps.md")
    "Time_Travel" = @("revert_to_previous.md", "time_based_execution.md", "undo_action.md")
    "Streaming" = @("stream_data.md", "real_time_processing.md", "continuous_execution.md")
    "Tool_calling" = @("api_integration.md", "external_tools.md", "plugin_support.md")
    "Subgraphs" = @("nested_graphs.md", "modular_design.md", "reuse_components.md")
    "Multi-agent" = @("agent_communication.md", "parallel_agents.md", "task_delegation.md")
    "State_Management" = @("global_state.md", "local_state.md", "event_driven_state.md")
    "Other" = @("miscellaneous.md", "experimental_features.md", "future_ideas.md")
    "Prebuilt_ReAct_Agent" = @("agent_workflow.md", "default_behaviors.md", "customization.md")
    "LangGraph_Platform" = @("architecture.md", "scalability.md", "performance.md")
    "Application_Structure" = @("project_setup.md", "modular_design.md", "best_practices.md")
    "Deployment" = @("cloud_deployment.md", "local_setup.md", "containerization.md")
    "Authentication_Access_Control" = @("user_roles.md", "permissions.md", "security_policies.md")
    "Assistants" = @("ai_assistants.md", "virtual_agents.md", "co-pilot_design.md")
    "Threads" = @("multi-threading.md", "parallel_processing.md", "thread_synchronization.md")
    "Runs" = @("execution_flow.md", "run_management.md", "task_scheduling.md")
    "Webhooks" = @("event_triggers.md", "callback_urls.md", "real_time_updates.md")
    "Cron_Jobs" = @("scheduled_tasks.md", "automation.md", "time_based_execution.md")
    "LangGraph_Studio" = @("ui_features.md", "debugging.md", "workflow_visualization.md")
    "Troubleshooting" = @("common_issues.md", "debugging_tips.md", "error_handling.md")
}

New-Item -ItemType Directory -Path "LangGraph" -Force | Out-Null
foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path "LangGraph\$folder" -Force | Out-Null
}
foreach ($folder in $files.Keys) {
    foreach ($file in $files[$folder]) {
        New-Item -ItemType File -Path "LangGraph\$folder\$file" -Force | Out-Null
    }
}

Write-Host "✅ All folders and files have been created successfully!" -ForegroundColor Green
