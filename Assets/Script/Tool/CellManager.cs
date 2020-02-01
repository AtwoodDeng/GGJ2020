using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CellManager : MonoBehaviour
{

    public CellVisual target1;
    public CellVisual target2;
    public CellVisual target3;
    public GUISkin skin;


    public void OnGUI()
    {
        GUI.skin = skin;

        if ( GUILayout.Button("Jiankang") )
        {
            target3.SetStateTo(target2.m_state);
            target2.SetStateTo(target1.m_state);
            target1.SetStateTo(CellVisual.CellState.Jiankang);
        }
        if (GUILayout.Button("Kangti"))
        {
            target3.SetStateTo(target2.m_state);
            target2.SetStateTo(target1.m_state);
            target1.SetStateTo(CellVisual.CellState.Kangti);
        }
        if (GUILayout.Button("Bingdu"))
        {
            target3.SetStateTo(target2.m_state);
            target2.SetStateTo(target1.m_state);
            target1.SetStateTo(CellVisual.CellState.Bingdu);
        }
        if (GUILayout.Button("Ganran"))
        {
            target3.SetStateTo(target2.m_state);
            target2.SetStateTo(target1.m_state);
            target1.SetStateTo(CellVisual.CellState.Ganran);
        }
        if (GUILayout.Button("Siwang"))
        {
            target3.SetStateTo(target2.m_state);
            target2.SetStateTo(target1.m_state);
            target1.SetStateTo(CellVisual.CellState.Siwang);
        }
    }
}
