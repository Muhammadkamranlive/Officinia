using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

using Server.DependencyInjection;

using Service.Database;

using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// --------------------------------------------------
//  CONNECTION STRING 
// --------------------------------------------------
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// --------------------------------------------------
//  EF CORE DATABASE CONTEXT
// --------------------------------------------------
builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlServer(connectionString);
});

// --------------------------------------------------
//  AUTOMATIC DI SCANNING (Repositories + Services)
// --------------------------------------------------
builder.Services.AddProjectDependencies();

//-----JWT---
builder.Services.AddAuthentication("Bearer")
    .AddJwtBearer("Bearer", options =>
    {
        var jwtSettings = builder.Configuration.GetSection("JwtSettings");

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer           = true,
            ValidateAudience         = true,
            ValidateIssuerSigningKey = true,
            ValidateLifetime         = true,

            ValidIssuer         = jwtSettings["Issuer"],
            ValidAudience       = jwtSettings["Audience"],
            IssuerSigningKey    = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["Key"]))
        };
    });

builder.Services.AddAuthorization();


var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    // ✅ Enable middleware to serve Swagger JSON
    app.UseSwagger();

    // ✅ Enable middleware to serve Swagger UI
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "My API v1");
        options.RoutePrefix = string.Empty; // Swagger UI at root (optional)
    });
}
// Enable Swagger always
app.UseSwagger();
app.UseSwaggerUI();
app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();