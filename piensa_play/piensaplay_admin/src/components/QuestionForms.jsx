import React from 'react';
import { Trash2, Plus, Check, Image, Music, X, Loader2, GripVertical, ArrowRight, Upload } from 'lucide-react';

/**
 * Helper component for media in questions
 */
const QuestionMediaZone = ({ type, url, onUpload, onRemove, uploading, progress }) => {
    const isUploading = uploading;

    if (isUploading) {
        return (
            <div className="q-media-upload uploading">
                <Loader2 className="spin" size={16} />
                <div className="q-progress-mini">
                    <div className="q-progress-fill" style={{ width: `${progress}%` }}></div>
                </div>
            </div>
        );
    }

    if (url) {
        return (
            <div className={`q-media-preview ${type}`}>
                {type === 'image' ? (
                    <img src={url} alt="Preview" />
                ) : (
                    <div className="audio-mini-pill">
                        <Music size={12} />
                        <span>Audio ok</span>
                    </div>
                )}
                <button type="button" className="q-remove-btn" onClick={onRemove}>
                    <X size={12} />
                </button>
            </div>
        );
    }

    return (
        <label className="q-upload-label">
            <input
                type="file"
                accept={type === 'image' ? "image/*" : "audio/*"}
                onChange={(e) => onUpload(e.target.files[0])}
                hidden
            />
            {type === 'image' ? <Image size={16} /> : <Music size={16} />}
            <span>{type === 'image' ? 'Imagen' : 'Audio'}</span>
        </label>
    );
};

// Quiz: Multiple choice questions
export const QuizQuestionForm = ({ question, index, onUpdate, onDelete, onMediaUpload, uploading, uploadProgress }) => (
    <div className="question-card">
        <div className="question-header">
            <span className="question-number">Pregunta {index + 1}</span>
            <div className="q-header-actions">
                <QuestionMediaZone
                    type="image"
                    url={question.imageUrl}
                    onUpload={(file) => onMediaUpload(file, 'image')}
                    onRemove={() => onUpdate('imageUrl', null)}
                    uploading={uploading[`q_${index}_image`]}
                    progress={uploadProgress[`q_${index}_image`]}
                />
                <button type="button" className="icon-btn delete" onClick={onDelete}>
                    <Trash2 size={14} />
                </button>
            </div>
        </div>
        <div className="question-content">
            <div className="form-group">
                <textarea
                    value={question.text || ''}
                    onChange={(e) => onUpdate('text', e.target.value)}
                    placeholder="Escribe la pregunta aquí..."
                    rows={2}
                />
            </div>
            <div className="form-group">
                <label className="small-label">Opciones de respuesta</label>
                <div className="options-grid-v2">
                    {(question.options || ['', '', '', '']).map((option, oIndex) => (
                        <div key={oIndex} className={`option-input-v2 ${question.correctIndex === oIndex ? 'correct' : ''}`}>
                            <button
                                type="button"
                                className="correct-circle"
                                onClick={() => onUpdate('correctIndex', oIndex)}
                            >
                                {question.correctIndex === oIndex ? <Check size={12} /> : oIndex + 1}
                            </button>
                            <input
                                type="text"
                                value={option}
                                onChange={(e) => {
                                    const newOptions = [...(question.options || ['', '', '', ''])];
                                    newOptions[oIndex] = e.target.value;
                                    onUpdate('options', newOptions);
                                }}
                                placeholder={`Opción ${oIndex + 1}`}
                            />
                        </div>
                    ))}
                </div>
            </div>
        </div>
    </div>
);

// Memory: Pairs of cards to match
export const MemoryQuestionForm = ({ question, index, onUpdate, onDelete, onMediaUpload, uploading, uploadProgress }) => (
    <div className="question-card">
        <div className="question-header">
            <span className="question-number">Par {index + 1}</span>
            <button type="button" className="icon-btn delete" onClick={onDelete}>
                <Trash2 size={14} />
            </button>
        </div>
        <div className="question-content">
            <div className="memory-pair-v2">
                <div className="memory-item">
                    <label>Carta A</label>
                    <div className="memory-input-box">
                        <textarea
                            value={question.cardA?.text || ''}
                            onChange={(e) => onUpdate('cardA', { ...question.cardA, text: e.target.value })}
                            placeholder="Texto..."
                            rows={1}
                        />
                        <QuestionMediaZone
                            type="image"
                            url={question.cardA?.image}
                            onUpload={(file) => onMediaUpload(file, `cardA_image`)}
                            onRemove={() => onUpdate('cardA', { ...question.cardA, image: null })}
                            uploading={uploading[`q_${index}_cardA_image`]}
                            progress={uploadProgress[`q_${index}_cardA_image`]}
                        />
                    </div>
                </div>
                <div className="pair-link">
                    <ArrowRight size={18} />
                </div>
                <div className="memory-item">
                    <label>Carta B (Par)</label>
                    <div className="memory-input-box">
                        <textarea
                            value={question.cardB?.text || ''}
                            onChange={(e) => onUpdate('cardB', { ...question.cardB, text: e.target.value })}
                            placeholder="Texto..."
                            rows={1}
                        />
                        <QuestionMediaZone
                            type="image"
                            url={question.cardB?.image}
                            onUpload={(file) => onMediaUpload(file, `cardB_image`)}
                            onRemove={() => onUpdate('cardB', { ...question.cardB, image: null })}
                            uploading={uploading[`q_${index}_cardB_image`]}
                            progress={uploadProgress[`q_${index}_cardB_image`]}
                        />
                    </div>
                </div>
            </div>
        </div>
    </div>
);

// Match Pairs: Connect related items
export const MatchPairsQuestionForm = ({ question, index, onUpdate, onDelete, onMediaUpload, uploading, uploadProgress }) => (
    <div className="question-card">
        <div className="question-header">
            <span className="question-number">Pareja {index + 1}</span>
            <button type="button" className="icon-btn delete" onClick={onDelete}>
                <Trash2 size={14} />
            </button>
        </div>
        <div className="question-content">
            <div className="match-row-v2">
                <div className="match-input-pair">
                    <input
                        type="text"
                        value={question.left || ''}
                        onChange={(e) => onUpdate('left', e.target.value)}
                        placeholder="Elemento 1"
                    />
                    <QuestionMediaZone
                        type="image"
                        url={question.leftImage}
                        onUpload={(file) => onMediaUpload(file, 'leftImage')}
                        onRemove={() => onUpdate('leftImage', null)}
                        uploading={uploading[`q_${index}_leftImage`]}
                        progress={uploadProgress[`q_${index}_leftImage`]}
                    />
                </div>
                <ArrowRight size={16} className="v-arrow" />
                <div className="match-input-pair">
                    <input
                        type="text"
                        value={question.right || ''}
                        onChange={(e) => onUpdate('right', e.target.value)}
                        placeholder="Elemento 2"
                    />
                    <QuestionMediaZone
                        type="image"
                        url={question.rightImage}
                        onUpload={(file) => onMediaUpload(file, 'rightImage')}
                        onRemove={() => onUpdate('rightImage', null)}
                        uploading={uploading[`q_${index}_rightImage`]}
                        progress={uploadProgress[`q_${index}_rightImage`]}
                    />
                </div>
            </div>
        </div>
    </div>
);

// Order Sequence: Items to order
export const OrderSequenceQuestionForm = ({ question, index, onUpdate, onDelete }) => (
    <div className="question-card">
        <div className="question-header">
            <span className="question-number">Secuencia {index + 1}</span>
            <button type="button" className="icon-btn delete" onClick={onDelete}>
                <Trash2 size={14} />
            </button>
        </div>
        <div className="question-content">
            <div className="form-group">
                <label className="small-label">Instrucción / Título</label>
                <input
                    type="text"
                    value={question.instruction || ''}
                    onChange={(e) => onUpdate('instruction', e.target.value)}
                    placeholder="Ej: Ordena los planetas..."
                />
            </div>
            <div className="form-group">
                <label className="small-label">Elementos en orden correcto (uno por línea)</label>
                <textarea
                    value={(question.items || []).join('\n')}
                    onChange={(e) => onUpdate('items', e.target.value.split('\n').filter(i => i.trim()))}
                    placeholder="Elemento 1&#10;Elemento 2&#10;Elemento 3"
                    rows={4}
                />
            </div>
        </div>
    </div>
);

// Fill Blanks: Complete the text
export const FillBlanksQuestionForm = ({ question, index, onUpdate, onDelete }) => (
    <div className="question-card">
        <div className="question-header">
            <span className="question-number">Oración {index + 1}</span>
            <button type="button" className="icon-btn delete" onClick={onDelete}>
                <Trash2 size={14} />
            </button>
        </div>
        <div className="question-content">
            <div className="form-group">
                <label className="small-label">Texto con ___ (guiones bajos) para el espacio</label>
                <textarea
                    value={question.text || ''}
                    onChange={(e) => onUpdate('text', e.target.value)}
                    placeholder="La capital de Italia es ___."
                    rows={2}
                />
            </div>
            <div className="form-group">
                <label className="small-label">Respuesta Correcta</label>
                <input
                    type="text"
                    value={question.answer || ''}
                    onChange={(e) => onUpdate('answer', e.target.value)}
                    placeholder="Roma"
                />
            </div>
        </div>
    </div>
);

// Word Selection: Select correct words
export const WordSelectionQuestionForm = ({ question, index, onUpdate, onDelete }) => (
    <div className="question-card">
        <div className="question-header">
            <span className="question-number">Sendero {index + 1}</span>
            <button type="button" className="icon-btn delete" onClick={onDelete}>
                <Trash2 size={14} />
            </button>
        </div>
        <div className="question-content">
            <div className="form-group">
                <label className="small-label">Palabras Correctas (separadas por coma)</label>
                <input
                    type="text"
                    value={(question.correctWords || []).join(', ')}
                    onChange={(e) => onUpdate('correctWords', e.target.value.split(',').map(s => s.trim()))}
                    placeholder="Ej: Sol, Playa, Verano"
                />
            </div>
            <div className="form-group">
                <label className="small-label">Palabras Incorrectas / Distractores</label>
                <input
                    type="text"
                    value={(question.distractors || []).join(', ')}
                    onChange={(e) => onUpdate('distractors', e.target.value.split(',').map(s => s.trim()))}
                    placeholder="Ej: Nieve, Frío, Invierno"
                />
            </div>
        </div>
    </div>
);

// Fake News: Identify if headline is real or fake
export const FakeNewsQuestionForm = ({ question, index, onUpdate, onDelete, onMediaUpload, uploading, uploadProgress }) => (
    <div className="question-card">
        <div className="question-header">
            <span className="question-number">Noticia {index + 1}</span>
            <div className="q-header-actions">
                <QuestionMediaZone
                    type="image"
                    url={question.imageUrl}
                    onUpload={(file) => onMediaUpload(file, 'imageUrl')}
                    onRemove={() => onUpdate('imageUrl', null)}
                    uploading={uploading[`q_${index}_imageUrl`]}
                    progress={uploadProgress[`q_${index}_imageUrl`]}
                />
                <button type="button" className="icon-btn delete" onClick={onDelete}>
                    <Trash2 size={14} />
                </button>
            </div>
        </div>
        <div className="question-content">
            <div className="form-group">
                <label className="small-label">Titular de la Noticia</label>
                <input
                    type="text"
                    value={question.headline || ''}
                    onChange={(e) => onUpdate('headline', e.target.value)}
                    placeholder="Ej: Un elefante vuela sobre Madrid"
                />
            </div>
            <div className="form-row-mini">
                <button
                    type="button"
                    className={`choice-btn real ${question.isReal === true ? 'active' : ''}`}
                    onClick={() => onUpdate('isReal', true)}
                >
                    Real
                </button>
                <button
                    type="button"
                    className={`choice-btn fake ${question.isReal === false ? 'active' : ''}`}
                    onClick={() => onUpdate('isReal', false)}
                >
                    Falsa
                </button>
            </div>
        </div>
    </div>
);

// Stereotype Breaker: Choose between options
export const StereotypeBreakerQuestionForm = ({ question, index, onUpdate, onDelete }) => (
    <div className="question-card">
        <div className="question-header">
            <span className="question-number">Escenario {index + 1}</span>
            <button type="button" className="icon-btn delete" onClick={onDelete}>
                <Trash2 size={14} />
            </button>
        </div>
        <div className="question-content">
            <div className="form-group">
                <label className="small-label">Situación / Estereotipo</label>
                <textarea
                    value={question.stereotype || ''}
                    onChange={(e) => onUpdate('stereotype', e.target.value)}
                    placeholder="Ej: ¿Quién debería cocinar en casa?"
                    rows={2}
                />
            </div>
            <div className="options-list-mini">
                {(question.options || ['', '', '']).map((opt, i) => (
                    <div key={i} className={`mini-opt ${question.correctIndex === i ? 'selected' : ''}`}>
                        <input
                            type="text"
                            value={opt}
                            onChange={(e) => {
                                const newOpts = [...question.options];
                                newOpts[i] = e.target.value;
                                onUpdate('options', newOpts);
                            }}
                            placeholder={`Opción ${i + 1}`}
                        />
                        <button type="button" onClick={() => onUpdate('correctIndex', i)}>
                            {question.correctIndex === i ? <Check size={12} /> : i + 1}
                        </button>
                    </div>
                ))}
            </div>
        </div>
    </div>
);

// Get default structure for a new question based on type
export const getDefaultQuestion = (type) => {
    const base = { id: Date.now() };
    switch (type) {
        case 'quiz':
            return { ...base, text: '', options: ['', '', '', ''], correctIndex: 0, imageUrl: null };
        case 'memory':
            return { ...base, cardA: { text: '', image: null }, cardB: { text: '', image: null } };
        case 'match_pairs':
            return { ...base, left: '', right: '', leftImage: null, rightImage: null };
        case 'order_sequence':
            return { ...base, instruction: '', items: [] };
        case 'fill_blanks':
            return { ...base, text: '', answer: '' };
        case 'word_selection':
            return { ...base, correctWords: [], distractors: [] };
        case 'fake_news':
            return { ...base, headline: '', content: '', isReal: null, explanation: '', imageUrl: null };
        case 'stereotype_breaker':
            return { ...base, stereotype: '', options: ['', '', ''], correctIndex: 0, message: '' };
        default:
            return { ...base, text: '', options: ['', '', '', ''], correctIndex: 0 };
    }
};

// Validate if questions are complete
export const validateQuestions = (type, questions) => {
    if (questions.length === 0) return { valid: false, message: 'Añade al menos una pregunta' };

    for (let i = 0; i < questions.length; i++) {
        const q = questions[i];
        switch (type) {
            case 'quiz':
                if (!q.text?.trim() && !q.imageUrl) return { valid: false, message: `Pregunta ${i + 1}: añade texto o imagen` };
                if (!q.options?.some(o => o.trim())) return { valid: false, message: `Pregunta ${i + 1}: añade opciones` };
                break;
            case 'memory':
                if (!q.cardA?.text && !q.cardA?.image) return { valid: false, message: `Par ${i + 1}: falta la carta A` };
                if (!q.cardB?.text && !q.cardB?.image) return { valid: false, message: `Par ${i + 1}: falta la carta B` };
                break;
            case 'match_pairs':
                if ((!q.left?.trim() && !q.leftImage) || (!q.right?.trim() && !q.rightImage)) return { valid: false, message: `Pareja ${i + 1}: completa ambos elementos` };
                break;
            case 'order_sequence':
                if ((q.items || []).length < 2) return { valid: false, message: `Secuencia ${i + 1}: añade al menos 2 elementos` };
                break;
            case 'fill_blanks':
                if (!q.text?.includes('___')) return { valid: false, message: `Oración ${i + 1}: usa ___ para el espacio` };
                if (!q.answer?.trim()) return { valid: false, message: `Oración ${i + 1}: falta la respuesta` };
                break;
            case 'word_selection':
                if ((q.correctWords || []).length === 0) return { valid: false, message: `Sendero ${i + 1}: añade palabras correctas` };
                break;
            case 'fake_news':
                if (!q.headline?.trim()) return { valid: false, message: `Noticia ${i + 1}: falta el titular` };
                if (q.isReal === null) return { valid: false, message: `Noticia ${i + 1}: indica si es real o falsa` };
                break;
            case 'stereotype_breaker':
                if (!q.stereotype?.trim()) return { valid: false, message: `Escenario ${i + 1}: falta la situación` };
                break;
        }
    }

    return { valid: true };
};

// Get the correct form component for each type
export const getQuestionForm = (type) => {
    switch (type) {
        case 'quiz': return QuizQuestionForm;
        case 'memory': return MemoryQuestionForm;
        case 'match_pairs': return MatchPairsQuestionForm;
        case 'order_sequence': return OrderSequenceQuestionForm;
        case 'fill_blanks': return FillBlanksQuestionForm;
        case 'word_selection': return WordSelectionQuestionForm;
        case 'fake_news': return FakeNewsQuestionForm;
        case 'stereotype_breaker': return StereotypeBreakerQuestionForm;
        default: return QuizQuestionForm;
    }
};

// Get minimum questions required for each type
export const getMinQuestions = (type) => {
    switch (type) {
        case 'memory': return 4; // Need at least 4 pairs
        case 'match_pairs': return 3;
        case 'order_sequence': return 1;
        default: return 1;
    }
};

// Get label for "Add Question" button based on type
export const getAddButtonLabel = (type) => {
    switch (type) {
        case 'memory': return 'Añadir Par';
        case 'match_pairs': return 'Añadir Pareja';
        case 'order_sequence': return 'Añadir Secuencia';
        case 'fill_blanks': return 'Añadir Oración';
        case 'word_selection': return 'Añadir Sendero';
        case 'fake_news': return 'Añadir Noticia';
        case 'stereotype_breaker': return 'Añadir Escenario';
        default: return 'Añadir Pregunta';
    }
};
