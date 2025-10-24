using UnityEngine;

[CreateAssetMenu(fileName = "NewItemDialogue", menuName = "Dialogue/ItemDialogue")]
public class ItemDialogue : ScriptableObject
{
    public string itemName;
    public DialogueNode[] dialogues;
}

[System.Serializable]
public class DialogueNode
{
    public string text;
    //public DialogueChoice[] choices;
}

[System.Serializable]
public class DialogueChoice
{
    public string choiceText;
    public int nextNodeIndex; // -1 for end of dialogue
}
