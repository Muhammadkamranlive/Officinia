using System.ComponentModel.DataAnnotations;

namespace Server.Domains;

public class App_User
{
    public int Id                       { get; set; } 
    public string Email                 { get; set; } = string.Empty;
    public string PhoneNumber           { get; set; } = string.Empty;
    public string FirstName             { get; set; } = string.Empty;
    public string LastName              { get; set; } = string.Empty;
    public string PasswordHash          { get; set; } = string.Empty;
    public DateTime? PasswordExpiryDate { get; set; }
    public int FailedLoginCount         { get; set; } = 0;
    public int InvalidLoginTries        { get; set; } = 0;
    public DateTime? LockoutUntil       { get; set; }
    public string CurrentSessionId      { get; set; } = string.Empty;
    public int CurrentLogins            { get; set; } = 0;
    public int ConcurrentLoginAllowed   { get; set; } = 1;
    public string ExternalProvider      { get; set; } = string.Empty; // "Google","Apple","Facebook","B2C"
    public string ExternalProviderId    { get; set; } = string.Empty;
    public bool TwoFactorEnabled        { get; set; } = false;
    public string TwoFactorMethod       { get; set; } = string.Empty; // "sms","authenticator","email"
    public string Role                  { get; set; } 
    public string Status                { get; set; } = "A"; // e.g., A = Active, I = Inactive, S = Suspended
    public DateTime CreationDate        { get; set; }
    public int? AuthorizedBy            { get; set; } 
    public DateTime? AuthorizedDate     { get; set; }
    public DateTime? ActivationDate     { get; set; }
    public DateTime? LastLoginDate      { get; set; }
    public bool IsDeleted               { get; set; } = false;
    
    // Constructor
    public App_User()
    {
        CreationDate = DateTime.UtcNow;
    }
}