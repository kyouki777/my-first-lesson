using UnityEngine;
using System.Collections.Generic;

[System.Serializable]


public struct Answer
{
    [SerializeField] private string info;
    public string Info { get { return info; } }

    [SerializeField] private bool isCorrect;
    public bool IsCorrect { get { return isCorrect; } }

}
[CreateAssetMenu(fileName = "New Questions", menuName = "Quiz/new Questions")]
public class Questions : ScriptableObject
{
    public enum AnswerType { Multi, Single }

    [SerializeField] private string info = string.Empty;
    public string Info { get { return info; } }

    [SerializeField] Answer[] answers = null;
    public Answer[] Answers { get { return answers; } }

    [SerializeField] private AnswerType answerType = AnswerType.Multi;
    public AnswerType GetAnswerType { get { return answerType; } }
    [SerializeField] private int addScore = 1;
    public int AddScore { get { return addScore; } }

    public List<int> GetCorrectAnswer()
    {
        List<int>  CorrectAnswers  = new List<int>();
        for (int i = 0; i < answers.Length; i++)
        {
            if (answers[i].IsCorrect)
            {
                CorrectAnswers.Add(i);
            }
        }
            return CorrectAnswers;
    }

}
