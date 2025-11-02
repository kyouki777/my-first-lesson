using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Tilemaps;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    [HideInInspector] public bool disableOnExit = false;
    [SerializeField] private GameObject youEscapedUI;

    #region Variables

    [Header("Door Settings")]
    [SerializeField] private GameObject closedDoorTilemap;
    [SerializeField] private GameObject openedDoorTilemap;
    [SerializeField] private GameObject escapeInteractionZone;
    public AudioSource doorAudio;

    [Header("Ending Slides")]
    [SerializeField] private List<CanvasGroup> endingSlides;
    [SerializeField] private float fadeDuration = 1f;
    [SerializeField] private float stayDuration = 1.5f;

    private bool doorUnlocked = false;

    private Questions[] _questions = null;
    public Questions[] QuestionList { get { return _questions; } }

    [SerializeField] GameEvents events = null;

    [SerializeField] Color timerHalfWayOutColor = Color.yellow;
    [SerializeField] Color timerAlmostOutColor = Color.red;
    private Color timerDefaultColor = Color.white;

    private List<AnswerData> PickedAnswers = new List<AnswerData>();
    private List<int> FinishedQuestions = new List<int>();
    private int currentQuestion = 0;

    private IEnumerator IE_WaitTillNextRound = null;

    private GameMode currentMode;
    private Questions currentGeneratedQuestion = null; // for Endless mode
    public TextMeshProUGUI textToHide; //in endless mode


    private bool IsFinished
    {
        get { return (FinishedQuestions.Count < QuestionList.Length) ? false : true; }
    }

    #endregion

    #region Unity Methods

    void OnEnable()
    {
        events.UpdateQuestionAnswer += UpdateAnswers;
    }

    void OnDisable()
    {
        events.UpdateQuestionAnswer -= UpdateAnswers;
    }

    void Awake()
    {
        Debug.Log("[GameManager] Awake — Mode: " + GameModeSelector.SelectedMode);
        events.CurrentFinalScore = 0;
    }

    void Start()
    {
        currentMode = GameModeSelector.SelectedMode;
        Debug.Log("[GameManager] Starting mode: " + currentMode);

        if (currentMode == GameMode.Story)
        {
            LoadQuestions();
        }
        else
        {
            currentGeneratedQuestion = GenerateRandomQuestion();
        }

        Display();
    }

    #endregion

    #region Endless Question Generator

    Questions GenerateRandomQuestion()
    {
        Questions q = ScriptableObject.CreateInstance<Questions>();

        int a = Random.Range(1, 20);
        int b = Random.Range(1, 20);
        string[] ops = { "+", "-", "*", "/" };
        string op = ops[Random.Range(0, ops.Length)];

        int correctAnswer = op switch
        {
            "+" => a + b,
            "-" => a - b,
            "*" => a * b,
            "/" => b != 0 ? a / b : 0,
            _ => 0
        };

        typeof(Questions).GetField("info", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            .SetValue(q, $"What is {a} {op} {b}?");

        List<Answer> answers = new List<Answer>();
        int correctIndex = Random.Range(0, 4);

        for (int j = 0; j < 4; j++)
        {
            Answer ans = new Answer();
            int optionValue = (j == correctIndex) ? correctAnswer : correctAnswer + Random.Range(-5, 6);

            typeof(Answer).GetField("info", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
                .SetValueDirect(__makeref(ans), optionValue.ToString());
            typeof(Answer).GetField("isCorrect", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
                .SetValueDirect(__makeref(ans), j == correctIndex);

            answers.Add(ans);
        }

        typeof(Questions).GetField("answers", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            .SetValue(q, answers.ToArray());
        typeof(Questions).GetField("answerType", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            .SetValue(q, Questions.AnswerType.Single);
        typeof(Questions).GetField("addScore", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            .SetValue(q, 1);

        return q;
    }

    #endregion

    #region Question Flow

    public void StartGameManually()
    {
        currentMode = GameModeSelector.SelectedMode;
        Debug.Log("[GameManager] Manual Start - Mode: " + currentMode);

        if (currentMode == GameMode.Endless)
        {
            currentGeneratedQuestion = GenerateRandomQuestion();
        }
        else
        {
            LoadQuestions();
        }

        Display();
    }

    void Display()
    {
        EraseAnswers();

        Questions question;

        if (currentMode == GameMode.Endless)
        {
            currentGeneratedQuestion = GenerateRandomQuestion();
            question = currentGeneratedQuestion;
            Debug.Log($"[GameManager] Showing new Endless question: {question.Info}");
        }
        else
        {
            question = GetRandomQuestion();
            Debug.Log($"[GameManager] Showing Story question: {question.Info}");
        }

        events.UpdateQuestionUI?.Invoke(question);
    }

    void LoadQuestions()
    {
        Debug.Log("Story questions loaded");
        Object[] objs = Resources.LoadAll("Questions", typeof(Questions));
        _questions = new Questions[objs.Length];
        for (int i = 0; i < objs.Length; i++)
        {
            _questions[i] = (Questions)objs[i];
        }
    }

    Questions GetRandomQuestion()
    {
        var randomIndex = GetRandomQuestionIndex();
        currentQuestion = randomIndex;
        return QuestionList[currentQuestion];
    }

    int GetRandomQuestionIndex()
    {
        var random = 0;
        if (FinishedQuestions.Count < QuestionList.Length)
        {
            do
            {
                random = UnityEngine.Random.Range(0, QuestionList.Length);
            } while (FinishedQuestions.Contains(random) || random == currentQuestion);
        }
        return random;
    }

    Questions GetActiveQuestion()
    {
        if (currentMode == GameMode.Endless)
            return currentGeneratedQuestion;
        else
            return QuestionList.Length > 0 ? QuestionList[currentQuestion] : null;
    }

    #endregion

    #region Answer and Score Handling

    public void UpdateAnswers(AnswerData newAnswer)
    {
        if (GetActiveQuestion().GetAnswerType == Questions.AnswerType.Single)
        {
            foreach (var answer in PickedAnswers)
            {
                if (answer != newAnswer) answer.Reset();
            }
            PickedAnswers.Clear();
            PickedAnswers.Add(newAnswer);
        }
        else
        {
            bool alreadyPicked = PickedAnswers.Exists(x => x == newAnswer);
            if (alreadyPicked) PickedAnswers.Remove(newAnswer);
            else PickedAnswers.Add(newAnswer);
        }
    }

    public void EraseAnswers() => PickedAnswers = new List<AnswerData>();

    public void Accept()
    {
        if (PickedAnswers.Count == 0)
        {
            Debug.Log("Accept() skipped — no answer picked yet.");
            return;
        }

        bool isCorrect = CheckAnswers();

        if (currentMode == GameMode.Story)
            FinishedQuestions.Add(currentQuestion);

        int scoreDelta = (isCorrect) ? GetActiveQuestion().AddScore : -GetActiveQuestion().AddScore;
        UpdateScore(scoreDelta);

        if (currentMode == GameMode.Story && IsFinished)
        {
            SetHighscore();
            DisableAllComputers();
        }

        var type = (currentMode == GameMode.Story && IsFinished)
            ? UIManager.ResolutionScreenType.Finish
            : (isCorrect) ? UIManager.ResolutionScreenType.Correct
            : UIManager.ResolutionScreenType.Incorrect;

        events.DisplayResolutionScreen?.Invoke(type, GetActiveQuestion().AddScore);

        ComputerAudioManager.Instance.PlaySound(isCorrect ? "CorrectSFX" : "IncorrectSFX", true);

        if (type != UIManager.ResolutionScreenType.Finish)
        {
            if (IE_WaitTillNextRound != null) StopCoroutine(IE_WaitTillNextRound);
            IE_WaitTillNextRound = WaitTillNextRound();
            StartCoroutine(IE_WaitTillNextRound);
        }
    }

    bool CheckAnswers() => CompareAnswers();

    bool CompareAnswers()
    {
        if (PickedAnswers.Count > 0)
        {
            List<int> c = GetActiveQuestion().GetCorrectAnswer();
            List<int> p = PickedAnswers.Select(x => x.AnswerIndex).ToList();

            var f = c.Except(p).ToList();
            var s = p.Except(c).ToList();

            return !f.Any() && !s.Any();
        }
        return false;
    }

    private IEnumerator WaitTillNextRound()
    {
        yield return new WaitForSeconds(GameUtility.ResolutionDelayTime);
        Display();
    }

    private void UpdateScore(int add)
    {
        events.CurrentFinalScore += add;
        events.ScoreUpdated?.Invoke();

        if (events.CurrentFinalScore >= 100)
        {
            UnlockDoor();
        }
    }

    #endregion

    #region Utility + Scene Flow

    public void RestartGame()
    {
        events.CurrentFinalScore = 0;
        FinishedQuestions.Clear();
        PickedAnswers.Clear();

        if (currentMode == GameMode.Story)
            LoadQuestions();
        else
            currentGeneratedQuestion = GenerateRandomQuestion();

        Display();
    }

    public void QuitGame() => Application.Quit();

    private void SetHighscore()
    {
        var highscore = PlayerPrefs.GetInt(GameUtility.SavePrefKey);
        if (highscore < events.CurrentFinalScore)
        {
            PlayerPrefs.SetInt(GameUtility.SavePrefKey, events.CurrentFinalScore);
        }
    }

    public void UnlockDoor()
    {
        doorUnlocked = true;

        if (closedDoorTilemap != null)
            closedDoorTilemap.SetActive(false);

        if (openedDoorTilemap != null)
            openedDoorTilemap.SetActive(true);

        if (escapeInteractionZone != null)
            escapeInteractionZone.SetActive(true);

        if (doorAudio != null)
            doorAudio.Play();

        Debug.Log("Door opened and escape zone activated!");
    }

    public void PlayerWins()
    {
        Debug.Log("Player has won the game!");
        Time.timeScale = 0f;
        StartCoroutine(FadeToOutroScene("OutroScene", 1.5f));
    }

    private IEnumerator FadeToOutroScene(string outroSceneName, float duration)
    {
        Debug.Log("[GameManager] Preparing white fade overlay...");

        GameObject fadeRoot = new GameObject("SceneFadeRoot");
        Canvas canvas = fadeRoot.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.sortingOrder = 999;

        fadeRoot.AddComponent<CanvasScaler>();
        fadeRoot.AddComponent<GraphicRaycaster>();

        GameObject fadeImageObj = new GameObject("FadeImage", typeof(RectTransform));
        fadeImageObj.transform.SetParent(fadeRoot.transform, false);
        UnityEngine.UI.Image fadeImage = fadeImageObj.AddComponent<UnityEngine.UI.Image>();
        fadeImage.color = new Color(1f, 1f, 1f, 0f);

        RectTransform rt = fadeImageObj.GetComponent<RectTransform>();
        rt.anchorMin = Vector2.zero;
        rt.anchorMax = Vector2.one;
        rt.offsetMin = Vector2.zero;
        rt.offsetMax = Vector2.zero;

        Debug.Log("[GameManager] Starting fade to white...");

        float t = 0f;
        while (t < duration)
        {
            t += Time.unscaledDeltaTime;
            float alpha = Mathf.Clamp01(t / duration);
            fadeImage.color = new Color(1f, 1f, 1f, alpha);
            yield return null;
        }

        fadeImage.color = Color.white;
        Debug.Log("[GameManager] Fade complete. Loading OutroScene...");

        Time.timeScale = 1f;
        SceneManager.LoadScene(outroSceneName);
    }

    private void DisableAllComputers()
    {
        disableOnExit = true;
    }

    #endregion
}
