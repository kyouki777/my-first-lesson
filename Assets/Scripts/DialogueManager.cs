using UnityEngine;
using TMPro;
using System.Collections;

public class DialogueManager : MonoBehaviour
{
    [Header("UI References")]
    public GameObject dialoguePanel;
    public TextMeshProUGUI dialogueText;

    [Header("Typing Effect")]
    public float typingSpeed = 0.03f;
    public AudioSource typingSound;

    private string[] currentDialogue;
    private int currentIndex;
    private Coroutine typingCoroutine;
    private bool isTyping = false;

    // --- START DIALOGUE ---
    
    public void StartDialogue(ItemDialogue itemDialogue)
    {
        if (dialoguePanel == null || dialogueText == null)
        {
            Debug.LogError("DialogueManager is missing UI references! Please assign them in the Inspector.");
            return;
        }

        if (itemDialogue == null)
        {
            Debug.LogError("ItemDialogue is null! Make sure your item has one assigned.");
            return;
        }

        dialoguePanel.SetActive(true);
        currentDialogue = new string[itemDialogue.dialogues.Length];

        // copy text from DialogueNode objects
        for (int i = 0; i < itemDialogue.dialogues.Length; i++)
        {
            currentDialogue[i] = itemDialogue.dialogues[i].text;
        }

        currentIndex = 0;
        ShowCurrentLine();
    }

    // --- DISPLAY CURRENT LINE ---
    void ShowCurrentLine()
    {
        if (currentIndex >= currentDialogue.Length)
        {
            EndDialogue();
            return;
        }

        if (typingCoroutine != null)
            StopCoroutine(typingCoroutine);

        typingCoroutine = StartCoroutine(TypeText(currentDialogue[currentIndex]));
    }

    // --- TYPEWRITER EFFECT ---
    IEnumerator TypeText(string fullText)
    {
        isTyping = true;
        dialogueText.text = "";

        foreach (char c in fullText)
        {
            dialogueText.text += c;

            if (typingSound != null)
            {
                typingSound.pitch = Random.Range(0.95f, 1.05f);
                typingSound.Play();
            }

            yield return new WaitForSeconds(typingSpeed);
        }

        isTyping = false;
    }

    // --- HANDLE INPUT ---
    void Update()
    {
        if (PauseManager.IsPaused)
            return;

        if (!dialoguePanel.activeSelf) return;

        if (Input.GetKeyDown(KeyCode.Space) || Input.GetMouseButtonDown(0))
        {
            if (isTyping)
            {
                // skip typing and show full text instantly
                StopCoroutine(typingCoroutine);
                dialogueText.text = currentDialogue[currentIndex];
                isTyping = false;
            }
            else
            {
                // go to next dialogue line
                currentIndex++;
                ShowCurrentLine();
            }
        }
    }

    // --- END DIALOGUE --
    public void EndDialogue()
    {
        if (typingCoroutine != null)
            StopCoroutine(typingCoroutine);

        dialoguePanel.SetActive(false);
        dialogueText.text = "";
        currentDialogue = null;
        isTyping = false;
    }
}
