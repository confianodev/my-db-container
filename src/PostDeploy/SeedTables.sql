PRINT 'Merging [Bible].[Verse]'

MERGE INTO [Bible].[Verse] AS TARGET
USING 
(
VALUES
    (1, 'Joao 15.16'),
    (2, 'Joao 15.17'),
    (3, 'Joao 15.18')
)
AS SOURCE ([VerseId], [Content])
ON TARGET.[VerseId] = SOURCE.[VerseId]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([VerseId], [Content])
    VALUES ([VerseId], [Content])
WHEN MATCHED THEN
    UPDATE SET
        TARGET.[Content] = SOURCE.[Content];