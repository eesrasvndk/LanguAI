using System;
using System.Collections.Generic;

namespace LanguAI.Models;

public partial class User
{
    public int Id { get; set; }

    public string Username { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string Password { get; set; } = null!;

    public string? EnglishLevel { get; set; }

    public string? LearningGoal { get; set; }

    public string? Interests { get; set; }

    public int? DailyTimeGoal { get; set; }

    public DateTime? CreatedAt { get; set; }
}
