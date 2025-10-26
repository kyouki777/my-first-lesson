using UnityEngine;

public class ItemInteract : MonoBehaviour
{
    [Header("Dialogue Settings")]
    public ItemDialogue bookshelfDialogue;   // Assign a unique dialogue per bookshelf

    [Header("UI Prompt")]
    public GameObject interactPrompt;         // "Press E" text or icon

    private bool playerInRange = false;
    private DialogueManager dialogueManager;

    void Start()
    {
        dialogueManager = FindObjectOfType<DialogueManager>();

        if (interactPrompt != null)
            interactPrompt.SetActive(false);
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            playerInRange = true;
            if (interactPrompt != null)
                interactPrompt.SetActive(true);
            Debug.Log("IN");
        }
    }

    void OnTriggerExit2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            playerInRange = false;
            if (interactPrompt != null)
                interactPrompt.SetActive(false);

            // hide dialogue when player leaves
            if (dialogueManager != null)
                dialogueManager.EndDialogue();

            Debug.Log("OUT");
        }
    }

    void Update()
    {
        if (PauseManager.IsPaused)
            return;

        if (playerInRange && Input.GetKeyDown(KeyCode.E))
        {
            if (dialogueManager != null && bookshelfDialogue != null)
            {
                dialogueManager.StartDialogue(bookshelfDialogue);
            }
        }
    }
}
