// -----------------------------------------------------------------------
// <copyright file="Containers.cs" company="Ascribe">
//      Copyright Ascribe Ltd
// </copyright>
// <summary>
// Gets the list of available containers for the current site 
// Read from WConfiguration
// Category: D|Container
// System: Empty string
//
// Usage
// var largestSyringe = Container.Instance().FindLargest(ContainerType.Syringe)
//
// Modification History:
// 18Jun15 XN Created 39882
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.pharmacydatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;

    using ascribe.pharmacy.shared;

    /// <summary>Type of container</summary>
    public enum ContainerType
    {
        /// <summary>Type unknown</summary>
        Unknown,

        /// <summary>Syringe type</summary>
        [EnumDBCode("S")]
        Syringe,

        /// <summary>Bag type</summary>
        [EnumDBCode("B")]
        Bag,

        /// <summary>Vial type</summary>
        [EnumDBCode("V")]
        Vial,

        /// <summary>Original type!</summary>
        [EnumDBCode("O")]
        Original
    }

    /// <summary>Container object</summary>
    public class Container
    {
        /// <summary>Prevents a default instance of the <see cref="Container"/> class from being created.</summary>
        private Container() {}

        /// <summary>Index in the container list (WConfiguration Key)</summary>
        public int Index;

        /// <summary>Type of container</summary>
        public ContainerType Type;

        /// <summary>Container name</summary>
        public string Description;

        /// <summary>Volume of container</summary>
        public double VolumeInmL;

        /// <summary>Load instance of containers</summary>
        /// <returns>Instance of containers</returns>
        public static IEnumerable<Container> Instance()
        {
            string cacheKey = "Container.Instance";

            // Try load results from cache
            List<Container> results = PharmacyDataCache.GetFromContext(cacheKey) as List<Container>;
            if (results == null)
            {
                results = new List<Container>();

                // Load all container settings
                WConfiguration configuration = new WConfiguration();
                configuration.LoadBySiteCategoryAndSection(SessionInfo.SiteID, "D|Container", string.Empty);

                foreach (var c in configuration)
                {
                    Container container = new Container();

                    // Convert index
                    if (!int.TryParse(c.Key, out container.Index))
                        continue;

                    // split value
                    string[] values = c.Value.Split('|');
                    if (values.Length < 5)
                        continue;

                    // Read value
                    container.Type = EnumDBCodeAttribute.DBCodeToEnum<ContainerType>(values[0]);
                    if (!double.TryParse(values[4], out container.VolumeInmL))
                        continue;
                    container.Description = values[1];

                    results.Add(container);
                }

                if (!results.Any())
                {
                    string msg = string.Format("There are no containers for site {0:000} in WConfiguration Category='D|Container' Section=''", SessionInfo.SiteNumber);
                    throw new ApplicationException(msg);
                }

                PharmacyDataCache.SaveToContext(cacheKey, results);
            }

            return results;
        }

        /// <summary>Returns Description</summary>
        /// <returns>Returns Description</returns>
        public override string ToString()
        {
            return this.Description;
        }
    }

    /// <summary>Container enumerator extension</summary>
    public static class ContainerEnumeratorExtension
    {
        /// <summary>Find the largest container of the specified type</summary>
        /// <param name="list">Container list</param>
        /// <param name="type">Type of container to find</param>
        /// <returns>Larges container of specified type</returns>
        public static Container FindLargest(this IEnumerable<Container> list, ContainerType type)
        {
            return list.Where(c => c.Type == type).OrderByDescending(c => c.VolumeInmL).FirstOrDefault();
        }
    }
}
