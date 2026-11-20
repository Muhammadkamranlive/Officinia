using Microsoft.Extensions.DependencyInjection;
using System.Reflection;

namespace Server.DependencyInjection
{
    public static class InjectionPackage
    {
        /// <summary>
        /// Main method
        /// </summary>
        /// <param name="services"></param>
        /// <returns></returns>
        public static IServiceCollection AddProjectDependencies(this IServiceCollection services)
        {
            var binPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            // Load all Server*.dll explicitly
            var assemblies = Directory.GetFiles(binPath, "Server*.dll")
                .Select(Assembly.LoadFrom)
                .ToList();

            foreach (var assembly in assemblies)
            {
                RegisterRepositories(services, assembly);
                RegisterServices(services, assembly);
            }

            return services;
        }
       /// <summary>
       /// Register Repos
       /// </summary>
       /// <param name="services"></param>
       /// <param name="assembly"></param>
        private static void RegisterRepositories(IServiceCollection services, Assembly assembly)
        {
            var repoTypes = assembly.GetTypes()
                .Where(t => t.IsClass && !t.IsAbstract && t.Name.EndsWith("_Repo"))
                .ToList();

            foreach (var impl in repoTypes)
            {
                var interfaceType = impl.GetInterfaces()
                    .FirstOrDefault(i => i.Name == "I" + impl.Name);

                if (interfaceType != null)
                {
                    services.AddScoped(interfaceType, impl); // Repositories = Scoped
                }
            }
        }

        private static void RegisterServices(IServiceCollection services, Assembly assembly)
        {
            var serviceTypes = assembly.GetTypes()
                .Where(t => t.IsClass && !t.IsAbstract && t.Name.EndsWith("_Service"))
                .ToList();

            foreach (var impl in serviceTypes)
            {
                var interfaceType = impl.GetInterfaces()
                    .FirstOrDefault(i => i.Name == "I" + impl.Name);

                if (interfaceType != null)
                {
                    services.AddTransient(interfaceType, impl); // Services = Transient
                }
            }
        }
    }
}
