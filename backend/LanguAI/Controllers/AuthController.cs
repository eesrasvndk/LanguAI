using System.Text.Json;
using LanguAI.Dtos;
using LanguAI.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Identity;

namespace LanguAI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly LanguAiContext _context;
        private readonly IConfiguration _configuration;

        // Constructors
        public AuthController(LanguAiContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto request)
        {
            // 1. Bu email ile daha önce kayıt olunmuş mu?
            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
            {
                return BadRequest("Bu email adresi zaten kullanımda.");
            }

            // 2. Yeni kullanıcı nesnesini oluştur (Mapping)
            var newUser = new User
            {
                Username = request.Username,
                Email = request.Email,
                // Şimdilik şifreyi düz kaydediyoruz. (Normalde Hashlenmeli!)
                Password = request.Password,

                EnglishLevel = request.EnglishLevel,
                LearningGoal = request.LearningGoal,
                DailyTimeGoal = request.DailyTimeGoal,
                Interests = JsonSerializer.Serialize(request.Interests),
            };

            // 3. Veritabanına ekle ve kaydet
            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            string token = CreateToken(newUser);

            return Ok(new
            {
                token = token,
                userId = newUser.Id,
                username = newUser.Username,
                message = "Kayıt başarılı! LanguAI dünyasına hoş geldin."
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody]LoginDto reguest)
        {
            var user = await _context.Users.FirstOrDefaultAsync(
                u => u.Email == reguest.Email);
            if (user == null)
            {
                return BadRequest("kullanıcı bulunamadı");
            }
            else if (user.Password != reguest.Password)
            {
                return BadRequest("şifre yanlış");
            }
            else if (user.Email != reguest.Email)
            {
                return BadRequest("email yanlış");
            }


            string token = CreateToken(user); //creating token
            return Ok(new //returning payload(user info)
            {
                token = token,
                userId =user.Id,
                username = user.Username,
            });

        }
         //token üretici method
         private string CreateToken(User user)
        {
            List<Claim> claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Email, user.Email)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration.GetSection("Jwt:Key").Value));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.Now.AddDays(30), // Token 30 gün geçerli olsun
                signingCredentials: creds,
                issuer: _configuration.GetSection("Jwt:Issuer").Value,
                audience: _configuration.GetSection("Jwt:Audience").Value
            );

            var jwt = new JwtSecurityTokenHandler().WriteToken(token);
            return jwt;
        }
    }
}
