using Microsoft.EntityFrameworkCore;
using Server.Configurations;

namespace Service.Database
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            // Scan the assembly where your configurations are
            var configAssembly = typeof(AppUser_Configuration).Assembly;
            
            var configTypes = configAssembly.GetTypes()
                .Where(t =>
                    t.Name.EndsWith("_Configuration") &&
                    !t.IsAbstract &&
                    t.GetInterfaces().Any(i =>
                        i.IsGenericType &&
                        i.GetGenericTypeDefinition() == typeof(IEntityTypeConfiguration<>)
                    )
                );

            foreach (var type in configTypes)
            {
                dynamic configInstance = Activator.CreateInstance(type);
                modelBuilder.ApplyConfiguration(configInstance);
            }
        }
    }
}