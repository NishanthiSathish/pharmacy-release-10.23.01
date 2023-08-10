--30Jan14 TH Added new versioning script to the conversion tools sp scripts. This should be run in via 
--           the bat file to esnure each set of sps can be versioned as a group

-- Add to Version Log
INSERT VersionLog ([Type], Description, [Date]) SELECT 'Config', 'v8 Conversion Tools  v1', GETDATE()
GO
select * from versionlog