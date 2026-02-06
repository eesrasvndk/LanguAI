using System.ComponentModel.DataAnnotations;

namespace LanguAI.Dtos
{
    public class RegisterDto
    {
        [Required]
        public string Username { get; set; }

        [Required]
        [EmailAddress]
        public string Email { get; set; }

        [Required]
        [MinLength(6)]
        public string Password { get; set; }

        public string EnglishLevel { get; set; } 
        public string LearningGoal { get; set; }
        public List<string> Interests { get; set; }
        public int DailyTimeGoal { get; set; } 
    }
}
