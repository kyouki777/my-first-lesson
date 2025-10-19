using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;

public class QuestionImporter : EditorWindow
{
    [MenuItem("Tools/Import Quiz Questions from CSV")]
    public static void ImportQuestions()
    {
        string path = EditorUtility.OpenFilePanel("Select Quiz CSV File", "", "csv");
        if (string.IsNullOrEmpty(path)) return;

        string[] lines = File.ReadAllLines(path);
        string folderPath = "Assets/Questions/Generated";
        if (!Directory.Exists(folderPath))
            Directory.CreateDirectory(folderPath);

        for (int i = 1; i < lines.Length; i++) // skip header
        {
            string[] parts = lines[i].Split(',');
            if (parts.Length < 9) continue;

            Questions q = ScriptableObject.CreateInstance<Questions>();

            // Use reflection to set private serialized fields
            var infoField = typeof(Questions).GetField("info", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            var answersField = typeof(Questions).GetField("answers", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            var answerTypeField = typeof(Questions).GetField("answerType", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            var addScoreField = typeof(Questions).GetField("addScore", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);

            infoField.SetValue(q, parts[0]);

            List<Answer> answerList = new List<Answer>();
            for (int j = 0; j < 3; j++)
            {
                string answerText = parts[1 + j * 2];
                bool isCorrect = bool.Parse(parts[2 + j * 2]);
                Answer answer = new Answer();

                // manually fill private struct fields
                var info = typeof(Answer).GetField("info", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                var correct = typeof(Answer).GetField("isCorrect", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
                info.SetValueDirect(__makeref(answer), answerText);
                correct.SetValueDirect(__makeref(answer), isCorrect);

                answerList.Add(answer);
            }

            answersField.SetValue(q, answerList.ToArray());
            answerTypeField.SetValue(q, parts[7] == "Single" ? Questions.AnswerType.Single : Questions.AnswerType.Multi);
            addScoreField.SetValue(q, int.Parse(parts[8]));

            AssetDatabase.CreateAsset(q, $"{folderPath}/Question_{i}.asset");
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        EditorUtility.DisplayDialog("Import Complete", "Questions imported successfully!", "OK");
    }
}
