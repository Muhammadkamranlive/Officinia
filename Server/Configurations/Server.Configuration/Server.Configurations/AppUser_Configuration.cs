using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Server.Domains;

namespace Server.Configurations;

public class AppUser_Configuration: IEntityTypeConfiguration<App_User>
{
    public void Configure(EntityTypeBuilder<App_User> builder)
    {
        builder.ToTable("App_User");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .ValueGeneratedOnAdd(); // Auto-increment

        builder.Property(x => x.Email)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(x => x.PhoneNumber)
            .HasMaxLength(20);

        builder.Property(x => x.FirstName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(x => x.LastName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(x => x.PasswordHash)
            .IsRequired()
            .HasMaxLength(500);

        builder.Property(x => x.CurrentSessionId)
            .HasMaxLength(200);

        builder.Property(x => x.ExternalProvider)
            .HasMaxLength(50);

        builder.Property(x => x.ExternalProviderId)
            .HasMaxLength(150);

        builder.Property(x => x.TwoFactorMethod)
            .HasMaxLength(20);

        builder.Property(x => x.Role)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(x => x.Status)
            .IsRequired()
            .HasMaxLength(2)
            .HasDefaultValue("A"); // Active by default
        builder.Property(x => x.CreationDate)
            .HasDefaultValueSql("GETUTCDATE()");
        builder.Property(x => x.IsDeleted)
            .HasDefaultValue(false);
    }
}